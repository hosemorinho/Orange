#!/bin/bash
. /lib/functions.sh
. /usr/share/openclash/ruby.sh
. /usr/share/openclash/openclash_ps.sh
. /usr/share/openclash/log.sh
. /lib/functions/procd.sh
. /usr/share/openclash/openclash_curl.sh
. /usr/share/openclash/uci.sh

# Global variables for secure cleanup
DECRYPT_FIFO=""
TEMP_FILES_TO_CLEAN=""

# Cleanup function for secure removal of temporary files
secure_cleanup() {
   if [ -n "$DECRYPT_FIFO" ] && [ -e "$DECRYPT_FIFO" ]; then
      rm -f "$DECRYPT_FIFO" 2>/dev/null
   fi
   if [ -n "$TEMP_FILES_TO_CLEAN" ]; then
      for f in $TEMP_FILES_TO_CLEAN; do
         rm -f "$f" 2>/dev/null
      done
   fi
}

# Register cleanup on EXIT, INT, TERM
trap secure_cleanup EXIT INT TERM

set_lock() {
   exec 889>"/tmp/lock/openclash_subs.lock" 2>/dev/null
   flock -x 889 2>/dev/null
}

del_lock() {
   flock -u 889 2>/dev/null
   rm -rf "/tmp/lock/openclash_subs.lock" 2>/dev/null
}

set_lock

LOGTIME=$(echo $(date "+%Y-%m-%d %H:%M:%S"))
LOG_FILE="/tmp/openclash.log"
CFG_FILE="/tmp/yaml_sub_tmp_config.yaml"
CRON_FILE="/etc/crontabs/root"
CONFIG_PATH=$(uci_get_config "config_path")
servers_update=$(uci_get_config "servers_update")
router_self_proxy=$(uci_get_config "router_self_proxy" || echo 1)
FW4=$(command -v fw4)
CLASH="/etc/openclash/clash"
CLASH_CONFIG="/etc/openclash"
restart=0
only_download=0

inc_job_counter

urlencode() {
   if [ "$#" -eq 1 ]; then
      echo "$(/usr/share/openclash/openclash_urlencode.lua "$1")"
   fi
}

xboard_trim_url() {
   local raw_url="$1"
   raw_url=$(echo "$raw_url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
   while [ "${raw_url%/}" != "$raw_url" ]; do
      raw_url="${raw_url%/}"
   done
   echo "$raw_url"
}

XBOARD_LUA="/usr/share/openclash/openclash_xboard.lua"

xboard_mask_url() {
   local raw_url="$1"
   local masked_url

   masked_url=$(XB_MODE="mask-url" XB_URL="$raw_url" /usr/bin/lua "$XBOARD_LUA" 2>/dev/null)
   if [ -n "$masked_url" ]; then
      echo "$masked_url"
   else
      raw_url=$(echo "$raw_url" | sed -E 's/([?&]token=)[^&]+/\1***MASKED***/g')
      raw_url=$(echo "$raw_url" | sed -E 's#(/subscription-encrypt/)[^/?&]+#\1***MASKED***#g')
      echo "$raw_url"
   fi
}

xboard_prepare_subscription() {
   local auth_mode="$1"
   local provider_token="$2"
   local provider_email="$3"
   local provider_password="$4"
   local sub_path="$5"
   local request_ua="$6"
   local output

   XBOARD_AUTH_TOKEN=""
   XBOARD_SUB_TOKEN=""
   XBOARD_SUBSCRIBE_URL=""

   output=$(XB_MODE="prepare" \
      XB_AUTH_MODE="$auth_mode" \
      XB_PROVIDER_TOKEN="$provider_token" \
      XB_PROVIDER_EMAIL="$provider_email" \
      XB_PROVIDER_PASSWORD="$provider_password" \
      XB_SUB_PATH="$sub_path" \
      XB_UA="$request_ua" \
      /usr/bin/lua "$XBOARD_LUA" 2>/dev/null)

   if [ $? -ne 0 ] || [ -z "$output" ]; then
      return 1
   fi

   XBOARD_AUTH_TOKEN=$(echo "$output" | sed -n 's/^AUTH_TOKEN=//p' | head -n 1)
   XBOARD_SUB_TOKEN=$(echo "$output" | sed -n 's/^SUB_TOKEN=//p' | head -n 1)
   XBOARD_SUBSCRIBE_URL=$(echo "$output" | sed -n 's/^SUBSCRIBE_URL=//p' | head -n 1)

   [ -n "$XBOARD_SUBSCRIBE_URL" ] && return 0 || return 1
}

xboard_decode_payload() {
   local cfg_file="$1"
   local enc_enable="$2"
   local enc_format="$3"
   local enc_algo="$4"
   local enc_key_ref="$5"
   local enc_key_value="$6"
   local enc_meta="$7"
   local sub_token="$8"
   local auth_token="$9"

   XB_MODE="decode" \
   XB_CFG_FILE="$cfg_file" \
   XB_ENC_ENABLE="$enc_enable" \
   XB_ENC_FORMAT="$enc_format" \
   XB_ENC_ALGO="$enc_algo" \
   XB_ENC_KEY_REF="$enc_key_ref" \
   XB_ENC_KEY_VALUE="$enc_key_value" \
   XB_ENC_META="$enc_meta" \
   XB_SUB_TOKEN="$sub_token" \
   XB_AUTH_TOKEN="$auth_token" \
   /usr/bin/lua "$XBOARD_LUA" >/dev/null 2>&1
}

# xboard_decode_payload_to_fifo: decrypt to FIFO for zero-landed plaintext
xboard_decode_payload_to_fifo() {
   local cfg_file="$1"
   local fifo_file="$2"
   local enc_enable="$3"
   local enc_format="$4"
   local enc_algo="$5"
   local enc_key_ref="$6"
   local enc_key_value="$7"
   local enc_meta="$8"
   local sub_token="$9"
   local auth_token="${10}"

   # Create FIFO with secure permissions
   rm -f "$fifo_file" 2>/dev/null
   mkfifo "$fifo_file" 2>/dev/null
   chmod 600 "$fifo_file" 2>/dev/null
   DECRYPT_FIFO="$fifo_file"

   XB_MODE="decode-fifo" \
   XB_CFG_FILE="$cfg_file" \
   XB_FIFO_FILE="$fifo_file" \
   XB_ENC_ENABLE="$enc_enable" \
   XB_ENC_FORMAT="$enc_format" \
   XB_ENC_ALGO="$enc_algo" \
   XB_ENC_KEY_REF="$enc_key_ref" \
   XB_ENC_KEY_VALUE="$enc_key_value" \
   XB_ENC_META="$enc_meta" \
   XB_SUB_TOKEN="$sub_token" \
   XB_AUTH_TOKEN="$auth_token" \
   /usr/bin/lua "$XBOARD_LUA" >/dev/null 2>&1 &
}

kill_streaming_unlock() {
   streaming_unlock_pids=$(unify_ps_pids "openclash_streaming_unlock.lua")
   for streaming_unlock_pid in $streaming_unlock_pids; do
      kill -9 "$streaming_unlock_pid" >/dev/null 2>&1
   done >/dev/null 2>&1
}

config_test()
{
   if [ -f "$CLASH" ]; then
      LOG_OUT "Config File Download Successful, Test If There is Any Errors..."
      test_info=$($CLASH -t -d $CLASH_CONFIG -f "$CFG_FILE")
      local IFS=$'\n'
      for i in $test_info; do
         if [ -n "$(echo "$i" |grep "configuration file")" ]; then
            local info=$(echo "$i" |sed "s# ${CFG_FILE} #{CONFIG_FILE}g")
            LOG_OUT "$info"
         else
            echo "$i" >> "$LOG_FILE"
         fi
      done
      if [ -n "$(echo "$test_info" |grep "test failed")" ]; then
         return 1
      fi
   else
      return 0
   fi
}

# config_test_fifo: test config from FIFO
config_test_fifo()
{
   local fifo_file="$1"
   if [ -f "$CLASH" ] && [ -p "$fifo_file" ]; then
      LOG_OUT "Config File Download Successful, Test If There is Any Errors (FIFO mode)..."
      test_info=$($CLASH -t -d $CLASH_CONFIG -f "$fifo_file")
      local IFS=$'\n'
      for i in $test_info; do
         if [ -n "$(echo "$i" |grep "configuration file")" ]; then
            local info=$(echo "$i" |sed "s# ${fifo_file} #{CONFIG_FILE}g")
            LOG_OUT "$info"
         else
            echo "$i" >> "$LOG_FILE"
         fi
      done
      if [ -n "$(echo "$test_info" |grep "test failed")" ]; then
         return 1
      fi
   else
      return 0
   fi
}

config_download()
{
LOG_OUT "Tip: Config File$nameDownloading User-Agent$sub_ua..."
if [ -n "$subscribe_url_param" ]; then
   if [ -n "$c_address" ]; then
      LOG_INFO "Tip: Config File$nameDownloading URL$(xboard_mask_url "$c_address$subscribe_url_param")..."
      DOWNLOAD_URL="${c_address}${subscribe_url_param}"
      DOWNLOAD_PARAM="$sub_ua"
   else
      LOG_INFO "Tip: Config File$nameDownloading URL$(xboard_mask_url "https://api.dler.io/sub$subscribe_url_param")..."
      DOWNLOAD_URL="https://api.dler.io/sub${subscribe_url_param}"
      DOWNLOAD_PARAM="$sub_ua"
   fi
else
   LOG_INFO "Tip: Config File$nameDownloading URL$(xboard_mask_url "$subscribe_url")..."
   DOWNLOAD_URL="${subscribe_url}"
   DOWNLOAD_PARAM="$sub_ua"
fi
DOWNLOAD_FILE_CURL "$DOWNLOAD_URL" "$CFG_FILE" "$DOWNLOAD_PARAM"
# Secure temporary file: set restrictive permissions immediately after download
if [ -f "$CFG_FILE" ]; then
   chmod 600 "$CFG_FILE" 2>/dev/null
   TEMP_FILES_TO_CLEAN="$TEMP_FILES_TO_CLEAN $CFG_FILE"
fi
}

# config_download_to_fifo: download config and write to FIFO for zero-landed plaintext
config_download_to_fifo()
{
local fifo_file="$1"
# Create FIFO with secure permissions
rm -f "$fifo_file" 2>/dev/null
mkfifo "$fifo_file" 2>/dev/null
chmod 600 "$fifo_file" 2>/dev/null
DECRYPT_FIFO="$fifo_file"
TEMP_FILES_TO_CLEAN="$TEMP_FILES_TO_CLEAN $fifo_file"

LOG_OUT "Tip: Config File$nameDownloading User-Agent$sub_ua... (FIFO mode)"
if [ -n "$subscribe_url_param" ]; then
   if [ -n "$c_address" ]; then
      LOG_INFO "Tip: Config File$nameDownloading URL$(xboard_mask_url "$c_address$subscribe_url_param")..."
      DOWNLOAD_URL="${c_address}${subscribe_url_param}"
      DOWNLOAD_PARAM="$sub_ua"
   else
      LOG_INFO "Tip: Config File$nameDownloading URL$(xboard_mask_url "https://api.dler.io/sub$subscribe_url_param")..."
      DOWNLOAD_URL="https://api.dler.io/sub${subscribe_url_param}"
      DOWNLOAD_PARAM="$sub_ua"
   fi
else
   LOG_INFO "Tip: Config File$nameDownloading URL$(xboard_mask_url "$subscribe_url")..."
   DOWNLOAD_URL="${subscribe_url}"
   DOWNLOAD_PARAM="$sub_ua"
fi
# Download to FIFO directly - plaintext never touches disk
DOWNLOAD_FILE_CURL "$DOWNLOAD_URL" "$fifo_file" "$DOWNLOAD_PARAM"
}

config_cus_up()
{
	if [ -z "$CONFIG_PATH" ]; then
      for file_name in /etc/openclash/config/*
      do
         if [ -f "$file_name" ]; then
            CONFIG_PATH=$file_name
            break
         fi
      done
      uci -q set openclash.config.config_path="$CONFIG_PATH"
      uci commit openclash
	fi
	if [ -z "$subscribe_url_param" ]; then
	   if [ -n "$key_match_param" ] || [ -n "$key_ex_match_param" ]; then
	      LOG_OUT "Config File$name】is Replaced Successfully, Start Picking Nodes..."
	      ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
	      begin
            threads = [];
	         Value = YAML.load_file('$CONFIG_FILE');
	         if Value.has_key?('proxies') and not Value['proxies'].to_a.empty? then
	            Value['proxies'].reverse.each{
	            |x|
                  if not '$key_match_param'.empty? then
                     threads << Thread.new {
                        if not /$key_match_param/i =~ x['name'] then
                           Value['proxies'].delete(x)
                           Value['proxy-groups'].each{
                              |g|
                              g['proxies'].reverse.each{
                                 |p|
                                 if p == x['name'] then
                                    g['proxies'].delete(p)
                                 end;
                              };
                           };
                        end;
                     };
                  end;
                  if not '$key_ex_match_param'.empty? then
                     threads << Thread.new {
                        if /$key_ex_match_param/i =~ x['name'] then
                           if Value['proxies'].include?(x) then
                              Value['proxies'].delete(x)
                              Value['proxy-groups'].each{
                                 |g|
                                 g['proxies'].reverse.each{
                                    |p|
                                    if p == x['name'] then
                                       g['proxies'].delete(p)
                                    end;
                                 };
                              };
                           end;
                        end;
                     };
                  end;
	            };
	         end;
            if Value.key?('proxy-providers') and not Value['proxy-providers'].nil? then
               Value['proxy-providers'].values.each do
                  |i|
                  threads << Thread.new {
                     if not '$key_match_param'.empty? then
                        i['filter'] = '(?i)$key_match_param';
                     end;
                     if not '$key_ex_match_param'.empty? then
                        i['exclude-filter'] = '(?i)$key_ex_match_param';
                     end;
                  };
               end;
            end;
            threads.each(&:join);
	      rescue Exception => e
	         YAML.LOG('Error: Filter Proxies Failed,? + e.message + '?);
	      ensure
	         File.open('$CONFIG_FILE','w') {|f| YAML.dump(Value, f)};
	      end" 2>/dev/null >> $LOG_FILE
	   fi
   fi
   if [ "$servers_update" -eq 1 ]; then
      LOG_OUT "Config File$name】is Replaced Successfully, Start to Reserving..."
      uci -q set openclash.config.config_update_path="/etc/openclash/config/$name.yaml"
      uci -q set openclash.config.servers_if_update=1
      uci commit openclash
      /usr/share/openclash/yml_groups_get.sh
      uci -q set openclash.config.servers_if_update=1
      uci commit openclash
      /usr/share/openclash/yml_groups_set.sh
      if [ "$CONFIG_FILE" == "$CONFIG_PATH" ]; then
         restart=1
      fi
      LOG_OUT "Config File$name】Update Successful!"
      SLOG_CLEAN
   elif [ "$CONFIG_FILE" == "$CONFIG_PATH" ]; then
      LOG_OUT "Config File$name】Update Successful!"
      restart=1
   else
      LOG_OUT "Config File$name】Update Successful!"
      SLOG_CLEAN
   fi

   rm -rf /tmp/Proxy_Group 2>/dev/null
}

config_su_check()
{
   LOG_OUT "Config File Test Successful, Check If There is Any Update..."
   sed -i 's/!<str> /!!str /g' "$CFG_FILE" >/dev/null 2>&1
   if [ -f "$CONFIG_FILE" ]; then
      cmp -s "$BACKPACK_FILE" "$CFG_FILE"
      if [ "$?" -ne 0 ]; then
         LOG_OUT "Config File$name】Are Updates, Start Replacing..."
         cp "$CFG_FILE" "$BACKPACK_FILE"
         #保留规则部分
         if [ "$servers_update" -eq 1 ] && [ "$only_download" -eq 0 ]; then
   	        ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
               Value = YAML.load_file('$CONFIG_FILE');
               Value_1 = YAML.load_file('$CFG_FILE');
               if Value.key?('rules') or Value.key?('script') or Value.key?('rule-providers') then
                  if Value.key?('rules') then
                     Value_1['rules'] = Value['rules']
                  end;
                  if Value.key?('script') then
                     Value_1['script'] = Value['script']
                  end;
                  if Value.key?('rule-providers') then
                     Value_1['rule-providers'] = Value['rule-providers']
                  end;
                  File.open('$CFG_FILE','w') {|f| YAML.dump(Value_1, f)};
               end;
            " 2>/dev/null
         fi
         mv "$CFG_FILE" "$CONFIG_FILE" 2>/dev/null
         if [ "$only_download" -eq 0 ]; then
            config_cus_up
         else
            LOG_OUT "Config File$name】Update Successful!"
            SLOG_CLEAN
         fi
      else
         LOG_OUT "Config File$name】No Change, Do Nothing!"
         rm -rf "$CFG_FILE"
         SLOG_CLEAN
      fi
   else
      LOG_OUT "Config File$name】Download Successful, Start To Create..."
      mv "$CFG_FILE" "$CONFIG_FILE" 2>/dev/null
      cp "$CONFIG_FILE" "$BACKPACK_FILE"
      if [ "$only_download" -eq 0 ]; then
         config_cus_up
      else
         LOG_OUT "Config File$name】Update Successful!"
         SLOG_CLEAN
      fi
   fi
}

config_error()
{
   LOG_OUT "Error:name】Update Error, Please Try Again Later..."
   rm -rf "$CFG_FILE" 2>/dev/null
   SLOG_CLEAN
   return 1
}

change_dns()
{
   if pidof clash >/dev/null; then
      /etc/init.d/openclash reload "restore" >/dev/null 2>&1
      procd_send_signal "openclash" "openclash-watchdog" CONT
   fi
}


config_download_direct()
{
   if pidof clash >/dev/null && [ "$router_self_proxy" = 1 ]; then
      kill_streaming_unlock
      procd_send_signal "openclash" "openclash-watchdog" STOP
      /etc/init.d/openclash reload "revert" >/dev/null 2>&1
      sleep 3

      # XBoard encrypted subscription: use FIFO for zero-landed plaintext
      if [ "$provider_type" = "xboard" ] && [ "$enc_enable" = "1" ]; then
         # Create FIFO for plaintext streaming
         FIFO_FILE="/tmp/openclash_fifo_$$_$name.yaml"
         rm -f "$FIFO_FILE" 2>/dev/null
         mkfifo "$FIFO_FILE" 2>/dev/null
         chmod 600 "$FIFO_FILE" 2>/dev/null
         DECRYPT_FIFO="$FIFO_FILE"
         TEMP_FILES_TO_CLEAN="$TEMP_FILES_TO_CLEAN $FIFO_FILE"

         config_download
         if [ "${PIPESTATUS[0]}" -eq 0 ] && [ -s "$CFG_FILE" ]; then
            # Decrypt to FIFO in background
            xboard_decode_payload_to_fifo "$CFG_FILE" "$FIFO_FILE" "$enc_enable" "$enc_format" "$enc_algo" "$enc_key_ref" "$enc_key_value" "$enc_meta" "$xboard_sub_token" "$xboard_auth_token" &
            DECRYPT_PID=$!
            wait $DECRYPT_PID 2>/dev/null

            if [ $? -ne 0 ]; then
               LOG_OUT "Error: Config File $name - Xboard Encrypted Decode Failed..."
               rm -f "$FIFO_FILE" 2>/dev/null
               change_dns
               config_error
               return
            fi

            # Test config from FIFO
            config_test_fifo "$FIFO_FILE"
            if [ $? -ne 0 ]; then
               LOG_OUT "Error: Config File Tested Failed, Please Check The Log Infos!"
               rm -f "$FIFO_FILE" 2>/dev/null
               change_dns
               config_error
               return
            fi

            # Validate YAML from FIFO
            ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
            begin
            yaml_content = STDIN.read;
            Value = YAML.load(yaml_content);
            rescue Exception => e
            YAML.LOG('Error: Unable To Parse Config File - ' + e.message + ' -');
            exit 1;
            end
            " < "$FIFO_FILE" 2>/dev/null >> $LOG_FILE

            if [ $? -ne 0 ]; then
               LOG_OUT "Error: Ruby Works Abnormally, Please Check The Ruby Library Depends!"
               rm -f "$FIFO_FILE" 2>/dev/null
               only_download=1
               change_dns
               config_su_check
            elif ! "$(ruby -ryaml -rYAML -e "
            yaml_content = STDIN.read;
            Value = YAML.load(yaml_content);
            print (Value.key?('proxies') || Value.key?('proxy-providers')).to_s
            " < "$FIFO_FILE" 2>/dev/null)" ; then
               LOG_OUT "Error: Updated Config $name - Has No Proxy Field, Update Exit..."
               rm -f "$FIFO_FILE" 2>/dev/null
               change_dns
               config_error
            else
               # Save config from FIFO to final location
               cat "$FIFO_FILE" > "$CONFIG_FILE"
               cp "$CONFIG_FILE" "$BACKPACK_FILE"
               rm -f "$FIFO_FILE" 2>/dev/null
               change_dns
               config_su_check
            fi
         else
            change_dns
            config_error
         fi
      else
         # Non-XBoard or unencrypted: use original flow
         config_download

         if [ "${PIPESTATUS[0]}" -eq 0 ] && [ -s "$CFG_FILE" ]; then
            xboard_decode_payload "$CFG_FILE" "$enc_enable" "$enc_format" "$enc_algo" "$enc_key_ref" "$enc_key_value" "$enc_meta" "$xboard_sub_token" "$xboard_auth_token"
            if [ $? -ne 0 ]; then
               LOG_OUT "Error: Config File $name - Xboard Encrypted Decode Failed..."
               change_dns
               config_error
               return
            fi
            #prevent ruby unexpected error
            sed -i -E 's/protocol-param: ([^,'"'"'"''}( *#)\n\r]+)/protocol-param: "\1"/g' "$CFG_FILE" 2>/dev/null
            sed -i '/^ \{0,\}enhanced-mode:/d' "$CFG_FILE" >/dev/null 2>&1
            config_test
            if [ $? -ne 0 ]; then
               LOG_OUT "Error: Config File Tested Failed, Please Check The Log Infos!"
               change_dns
               config_error
               return
            fi
            ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
            begin
            YAML.load_file('$CFG_FILE');
            rescue Exception => e
            YAML.LOG('Error: Unable To Parse Config File - ' + e.message + ' -');
            system 'rm -rf ${CFG_FILE} 2>/dev/null'
            end
            " 2>/dev/null >> $LOG_FILE
            if [ $? -ne 0 ]; then
               LOG_OUT "Error: Ruby Works Abnormally, Please Check The Ruby Library Depends!"
               only_download=1
               change_dns
               config_su_check
            elif [ ! -f "$CFG_FILE" ]; then
               LOG_OUT "Config File Format Validation Failed..."
               change_dns
               config_error
            elif ! "$(ruby_read "$CFG_FILE" ".key?('proxies')")" && ! "$(ruby_read "$CFG_FILE" ".key?('proxy-providers')")" ; then
               LOG_OUT "Error: Updated Config $name - Has No Proxy Field, Update Exit..."
               change_dns
               config_error
            else
               change_dns
               config_su_check
            fi
         else
            change_dns
            config_error
         fi
      fi
   else
      config_error
   fi
}
server_key_match()
{
	local key_match key_word

   if [ -n "$(echo "$1" |grep "^ \{0,\}$")" ] || [ -n "$(echo "$1" |grep "^\t\{0,\}$")" ]; then
	    return
   fi

   if [ -n "$(echo "$1" |grep "&")" ]; then
      key_word=$(echo "$1" |sed 's/&/ /g')
	    for k in $key_word
	    do
	       if [ -z "$k" ]; then
	          continue
	       fi
	       k="(?=.*$k)"
	       key_match="$key_match$k"
	    done
	    key_match="^($key_match).*"
   else
	    if [ -n "$1" ]; then
	       key_match="($1)"
	    fi
   fi

   if [ "$2" = "keyword" ]; then
      if [ -z "$key_match_param" ]; then
         key_match_param="$key_match"
      else
         key_match_param="$key_match_param|$key_match"
      fi
   elif [ "$2" = "ex_keyword" ]; then
   	  if [ -z "$key_ex_match_param" ]; then
         key_ex_match_param="$key_match"
      else
         key_ex_match_param="$key_ex_match_param|$key_match"
      fi
   fi
}

convert_custom_param()
{
   if ! (echo "$1" | grep -qE "^\w+=.+$") then
      return
   fi
   local p_name="${1%%=*}" p_value="${1#*=}"
   if [ -z "$append_custom_params" ]; then
      append_custom_params="&${p_name}=$(urlencode "$p_value")"
   else
      append_custom_params="${append_custom_params}\`$(urlencode "$p_value")"
   fi
}

sub_info_get()
{
   local section="$1" subscribe_url template_path subscribe_url_param template_path_encode key_match_param key_ex_match_param c_address de_ex_keyword sub_ua append_custom_params
   local provider_type provider_auth_ref xboard_email xboard_password xboard_token xboard_sub_path
   local enc_enable enc_format enc_algo enc_key_ref enc_meta enc_key_value
   local xboard_sub_token xboard_auth_token
   config_get_bool "enabled" "$section" "enabled" "1"
   config_get "name" "$section" "name" ""
   config_get "sub_convert" "$section" "sub_convert" ""
   config_get "address" "$section" "address" ""
   config_get "keyword" "$section" "keyword" ""
   config_get "ex_keyword" "$section" "ex_keyword" ""
   config_get "emoji" "$section" "emoji" ""
   config_get "udp" "$section" "udp" ""
   config_get "skip_cert_verify" "$section" "skip_cert_verify" ""
   config_get "sort" "$section" "sort" ""
   config_get "convert_address" "$section" "convert_address" ""
   config_get "template" "$section" "template" ""
   config_get "node_type" "$section" "node_type" ""
   config_get "rule_provider" "$section" "rule_provider" ""
   config_get "custom_template_url" "$section" "custom_template_url" ""
   config_get "de_ex_keyword" "$section" "de_ex_keyword" ""
   config_get "sub_ua" "$section" "sub_ua" "clash.meta"
   config_get "provider_type" "$section" "provider_type" "default"
   config_get "provider_auth_ref" "$section" "provider_auth_ref" "auto"
   config_get "xboard_email" "$section" "xboard_email" ""
   config_get "xboard_password" "$section" "xboard_password" ""
   config_get "xboard_token" "$section" "xboard_token" ""
   config_get "xboard_sub_path" "$section" "xboard_sub_path" "/api/v1/client/subscribe?token={token}"
   config_get "enc_enable" "$section" "enc_enable" "0"
   config_get "enc_format" "$section" "enc_format" "json-envelope"
   config_get "enc_algo" "$section" "enc_algo" "aes-256-cbc"
   config_get "enc_key_ref" "$section" "enc_key_ref" "token-sha256"
   config_get "enc_meta" "$section" "enc_meta" "iv=iv,data=data,tag=tag,cipher=cipher,format=format"
   config_get "enc_key_value" "$section" "enc_key_value" ""

   # Cleanup deprecated xboard_base_url legacy field.
   uci -q delete "openclash.$section.xboard_base_url" >/dev/null 2>&1

   if [ "$enabled" -eq 0 ]; then
      if [ -n "$2" ]; then
         if [ "$2" != "$CONFIG_FILE" ] && [ "$2" != "$name" ]; then
            return
         fi
      else
         return
      fi
   fi

   if [ -z "$address" ] && [ "$provider_type" != "xboard" ]; then
      return
   fi

   if [ "$udp" == "true" ]; then
      udp="&udp=true"
   else
      udp=""
   fi

   if [ "$rule_provider" == "true" ]; then
      rule_provider="&expand=false&classic=true"
   else
      rule_provider=""
   fi

   if [ -z "$name" ]; then
      name="config"
      CONFIG_FILE="/etc/openclash/config/config.yaml"
      BACKPACK_FILE="/etc/openclash/backup/config.yaml"
   else
      CONFIG_FILE="/etc/openclash/config/$name.yaml"
      BACKPACK_FILE="/etc/openclash/backup/$name.yaml"
   fi

   if [ -n "$2" ] && [ "$2" != "$CONFIG_FILE" ] && [ "$2" != "$name" ]; then
      return
   fi

   if [ ! -z "$keyword" ] || [ ! -z "$ex_keyword" ]; then
      config_list_foreach "$section" "keyword" server_key_match "keyword"
      config_list_foreach "$section" "ex_keyword" server_key_match "ex_keyword"
   fi

   if [ -n "$de_ex_keyword" ]; then
      for i in $de_ex_keyword;
      do
      	if [ -z "$key_ex_match_param" ]; then
      	   key_ex_match_param="($i)"
      	else
      	   key_ex_match_param="$key_ex_match_param|($i)"
        fi
      done
   fi

   if [ "$provider_type" = "xboard" ]; then
      xboard_prepare_subscription "$provider_auth_ref" "$xboard_token" "$xboard_email" "$xboard_password" "$xboard_sub_path" "$sub_ua"
      if [ $? -ne 0 ] || [ -z "$XBOARD_SUBSCRIBE_URL" ]; then
         LOG_OUT "Error: Config File$name 銆慲board Subscription Prepare Failed..."
         config_error
         return
      fi
      xboard_sub_token="$XBOARD_SUB_TOKEN"
      xboard_auth_token="$XBOARD_AUTH_TOKEN"
      subscribe_url="$XBOARD_SUBSCRIBE_URL"
      subscribe_url_param=""
      c_address=""
      sub_convert=0
   elif [ "$sub_convert" -eq 0 ]; then
      subscribe_url=$address
   elif [ "$sub_convert" -eq 1 ] && [ -n "$template" ]; then
      while read line
      do
      	subscribe_url=$([ -n "$subscribe_url" ] && echo "$subscribe_url|")$(urlencode "$line")
      done < <(echo "$address")
      if [ "$template" != "0" ]; then
         template_path=$(grep "^$template," /usr/share/openclash/res/sub_ini.list |awk -F ',' '{print $3}' 2>/dev/null)
      else
         template_path=$custom_template_url
      fi
      if [ -n "$template_path" ]; then
         config_list_foreach "$section" "custom_params" convert_custom_param
         template_path_encode=$(urlencode "$template_path")
         [ -n "$key_match_param" ] && key_match_param="$(urlencode "(?i)$key_match_param")"
         [ -n "$key_ex_match_param" ] && key_ex_match_param="$(urlencode "(?i)$key_ex_match_param")"
         subscribe_url_param="?target=clash&new_name=true&url=$subscribe_url&config=$template_path_encode&include=$key_match_param&exclude=$key_ex_match_param&emoji=$emoji&list=false&sort=$sort$udp&scv=$skip_cert_verify&append_type=$node_type&fdn=true$rule_provider$append_custom_params"
         c_address="$convert_address"
      else
         subscribe_url=$address
      fi
   else
      subscribe_url=$address
   fi


   LOG_OUT "Start Updating Config File$name?.."

   # XBoard encrypted subscription: use FIFO for zero-landed plaintext
   if [ "$provider_type" = "xboard" ] && [ "$enc_enable" = "1" ]; then
      # Create FIFO for plaintext streaming
      FIFO_FILE="/tmp/openclash_fifo_$$_$name.yaml"
      rm -f "$FIFO_FILE" 2>/dev/null
      mkfifo "$FIFO_FILE" 2>/dev/null
      chmod 600 "$FIFO_FILE" 2>/dev/null
      DECRYPT_FIFO="$FIFO_FILE"
      TEMP_FILES_TO_CLEAN="$TEMP_FILES_TO_CLEAN $FIFO_FILE"

      # Download encrypted content to temp file
      config_download
      if [ "${PIPESTATUS[0]}" -eq 0 ] && [ -s "$CFG_FILE" ]; then
         # Decrypt to FIFO in background
         xboard_decode_payload_to_fifo "$CFG_FILE" "$FIFO_FILE" "$enc_enable" "$enc_format" "$enc_algo" "$enc_key_ref" "$enc_key_value" "$enc_meta" "$xboard_sub_token" "$xboard_auth_token" &
         DECRYPT_PID=$!

         # Wait for decryption to complete
         wait $DECRYPT_PID 2>/dev/null
         if [ $? -ne 0 ]; then
            LOG_OUT "Error: Config File $name - Xboard Encrypted Decode Failed, Trying to Download Without Agent..."
            rm -f "$FIFO_FILE" 2>/dev/null
            config_download_direct
            return
         fi

         # Test config from FIFO
         config_test_fifo "$FIFO_FILE"
         if [ $? -ne 0 ]; then
            LOG_OUT "Error: Config File Tested Failed, Please Check The Log Infos!"
            LOG_OUT "Error: Config File $name - Subscribed Failed, Trying to Download Without Agent..."
            rm -f "$FIFO_FILE" 2>/dev/null
            config_download_direct
            return
         fi

         # Read YAML from FIFO and validate
         ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
         begin
         yaml_content = STDIN.read;
         Value = YAML.load(yaml_content);
         rescue Exception => e
         YAML.LOG('Error: Unable To Parse Config File - ' + e.message + ' -');
         exit 1;
         end
         " < "$FIFO_FILE" 2>/dev/null >> $LOG_FILE
         if [ $? -ne 0 ]; then
            LOG_OUT "Error: Ruby Works Abnormally, Please Check The Ruby Library Depends!"
            rm -f "$FIFO_FILE" 2>/dev/null
            only_download=1
            config_su_check
         elif ! "$(ruby -ryaml -rYAML -e "
         yaml_content = STDIN.read;
         Value = YAML.load(yaml_content);
         print (Value.key?('proxies') || Value.key?('proxy-providers')).to_s
         " < "$FIFO_FILE" 2>/dev/null)" ; then
            LOG_OUT "Error: Updated Config $name - Has No Proxy Field, Trying To Download Without Agent..."
            rm -f "$FIFO_FILE" 2>/dev/null
            config_download_direct
         else
            # Save config from FIFO to final location
            cat "$FIFO_FILE" > "$CONFIG_FILE"
            cp "$CONFIG_FILE" "$BACKPACK_FILE"
            rm -f "$FIFO_FILE" 2>/dev/null
            config_cus_up
         fi
      else
         LOG_OUT "Error: Config File $name - Subscribed Failed, Trying to Download Without Agent..."
         rm -f "$FIFO_FILE" 2>/dev/null
         config_download_direct
      fi
   else
      # Non-XBoard or unencrypted: use original flow
      config_download
      if [ "${PIPESTATUS[0]}" -eq 0 ] && [ -s "$CFG_FILE" ]; then
         xboard_decode_payload "$CFG_FILE" "$enc_enable" "$enc_format" "$enc_algo" "$enc_key_ref" "$enc_key_value" "$enc_meta" "$xboard_sub_token" "$xboard_auth_token"
         if [ $? -ne 0 ]; then
            LOG_OUT "Error: Config File $name - Xboard Encrypted Decode Failed, Trying to Download Without Agent..."
            config_download_direct
            return
         fi
         #prevent ruby unexpected error
         sed -i -E 's/protocol-param: ([^,'"'"'"''}( *#)\n\r]+)/protocol-param: "\1"/g' "$CFG_FILE" 2>/dev/null
         sed -i '/^ \{0,\}enhanced-mode:/d' "$CFG_FILE" >/dev/null 2>&1
         config_test
         if [ $? -ne 0 ]; then
            LOG_OUT "Error: Config File Tested Failed, Please Check The Log Infos!"
            LOG_OUT "Error: Config File $name - Subscribed Failed, Trying to Download Without Agent..."
            config_download_direct
            return
         fi
         ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
         begin
         YAML.load_file('$CFG_FILE');
         rescue Exception => e
         YAML.LOG('Error: Unable To Parse Config File - ' + e.message + ' -');
         system 'rm -rf ${CFG_FILE} 2>/dev/null'
         end
         " 2>/dev/null >> $LOG_FILE
         if [ $? -ne 0 ]; then
            LOG_OUT "Error: Ruby Works Abnormally, Please Check The Ruby Library Depends!"
            only_download=1
            config_su_check
         elif [ ! -f "$CFG_FILE" ]; then
            LOG_OUT "Config File Format Validation Failed, Trying To Download Without Agent..."
            config_download_direct
         elif ! "$(ruby_read "$CFG_FILE" ".key?('proxies')")" && ! "$(ruby_read "$CFG_FILE" ".key?('proxy-providers')")" ; then
            LOG_OUT "Error: Updated Config $name - Has No Proxy Field, Trying To Download Without Agent..."
            config_download_direct
         else
            config_su_check
         fi
      else
         LOG_OUT "Error: Config File $name - Subscribed Failed, Trying to Download Without Agent..."
         config_download_direct
      fi
   fi
}

#分别获取订阅信息进行处理
config_load "openclash"
config_foreach sub_info_get "config_subscribe" "$1"
uci -q delete openclash.config.config_update_path
uci commit openclash

dec_job_counter_and_restart "$restart"
del_lock
