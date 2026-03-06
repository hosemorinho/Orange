(function () {
  "use strict";

  var boot = window.__OC_XBOARD_BOOTSTRAP__ || {};
  var i18n = boot.i18n || {};
  var TOKEN_KEY = "oc_xboard_auth_data";

  var ORDER_STATUS = {
    0: "order_status_pending",
    1: "order_status_processing",
    2: "order_status_completed",
    3: "order_status_cancelled"
  };
  var ORDER_STATUS_CLS = {
    0: "pending",
    1: "processing",
    2: "completed",
    3: "cancelled"
  };

  var PERIOD_LABEL_KEY = {
    month_price: "period_month",
    quarter_price: "period_quarter",
    half_year_price: "period_half_year",
    year_price: "period_year",
    two_year_price: "period_two_year",
    three_year_price: "period_three_year",
    onetime_price: "period_onetime"
  };

  var state = {
    token: localStorage.getItem(TOKEN_KEY) || "",
    baseUrl: "",
    page: "home",
    user: null,
    subscribe: null,
    stat: null,
    notices: [],
    plans: [],
    tickets: [],
    ticketDetail: null,
    invite: null,
    inviteDetails: [],
    guestConfig: null,
    passportConfig: null,
    orders: [],
    orderDetail: null,
    orderFilter: -1,
    trafficLogs: [],
    trafficTotal: 0,
    commConfig: null,
    guestPlans: [],
    paymentPolling: null
  };

  function $(id) {
    return document.getElementById(id);
  }

  function t(key, fallback) {
    var msg = i18n[key];
    if (typeof msg === "string" && msg !== "") return msg;
    return fallback || key;
  }

  function tf(key, vars, fallback) {
    var text = t(key, fallback);
    if (!vars || typeof vars !== "object") return text;
    return text.replace(/\{([a-zA-Z0-9_]+)\}/g, function (_, name) {
      return vars[name] !== undefined && vars[name] !== null ? String(vars[name]) : "";
    });
  }

  function toOrderStatus(value) {
    var n = Number(value);
    return Number.isFinite(n) ? n : -1;
  }

  function setNotice(msg, type) {
    var box = $("noticeBox");
    if (!box) return;
    if (!msg) {
      box.className = "xb-notice hidden";
      box.textContent = "";
      return;
    }
    box.className = "xb-notice " + (type || "info");
    box.textContent = msg;
  }

  function setApiState(ok, label) {
    var dot = $("apiDot");
    var txt = $("apiStatus");
    if (dot) dot.classList.toggle("ok", !!ok);
    if (txt) txt.textContent = label || (ok ? t("api_connected", "API Connected") : t("api_disconnected", "API Disconnected"));
  }

  function escapeHtml(v) {
    return String(v || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function stripHtml(v) {
    return String(v || "").replace(/<[^>]*>/g, " ");
  }

  function fmtDate(v) {
    var n = Number(v || 0);
    if (!Number.isFinite(n) || n <= 0) return "-";
    var d = new Date(n * 1000);
    if (isNaN(d.getTime())) return "-";
    return d.toLocaleString();
  }

  function fmtTraffic(v) {
    var n = Number(v || 0);
    if (!Number.isFinite(n) || n < 0) return "0 B";
    var units = ["B", "KB", "MB", "GB", "TB"];
    var idx = 0;
    while (n >= 1024 && idx < units.length - 1) {
      n /= 1024;
      idx += 1;
    }
    return n.toFixed(idx === 0 ? 0 : 2) + " " + units[idx];
  }

  function safeData(obj) {
    if (!obj || typeof obj !== "object") return {};
    if (obj.data && typeof obj.data === "object") return obj.data;
    return obj;
  }

  function msgFromPayload(payload, fallback) {
    fallback = fallback || t("request_failed", "Request failed");
    if (!payload) return fallback;
    if (typeof payload.message === "string" && payload.message) return payload.message;
    if (payload.data && typeof payload.data.message === "string" && payload.data.message) return payload.data.message;
    if (payload.data && payload.data.errors && typeof payload.data.errors === "object") {
      var keys = Object.keys(payload.data.errors);
      if (keys.length) {
        var first = payload.data.errors[keys[0]];
        if (Array.isArray(first) && first.length) return String(first[0]);
        if (typeof first === "string") return first;
      }
    }
    if (typeof payload.raw === "string" && payload.raw.trim() !== "") return payload.raw.slice(0, 160);
    return fallback;
  }

  async function fetchJson(url, options) {
    var resp = await fetch(url, options || {});
    try {
      return await resp.json();
    } catch (_e) {
      return { ok: false, message: t("response_not_json", "Response is not JSON") };
    }
  }

  async function proxy(path, opts) {
    opts = opts || {};
    var method = (opts.method || "GET").toUpperCase();
    var auth = opts.auth !== false;
    if (auth && !state.token) throw new Error(t("not_logged_in", "Not logged in, please login first"));

    var body = new URLSearchParams();
    body.set("method", method);
    body.set("path", path);
    if (auth) body.set("auth_data", state.token);
    if (opts.data !== undefined) body.set("data", JSON.stringify(opts.data));
    if (opts.query !== undefined) body.set("query", JSON.stringify(opts.query));

    var payload = await fetchJson(boot.proxy_url, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      credentials: "same-origin",
      body: body.toString()
    });

    if (!payload || payload.ok !== true) {
      throw new Error(msgFromPayload(payload, t("proxy_request_failed", "Proxy request failed")));
    }
    return payload.data || {};
  }

  function showAuth(show) {
    $("authPane").classList.toggle("hidden", !show);
    $("panelPane").classList.toggle("hidden", show);
  }

  function switchAuthTab(tab) {
    var map = { login: "loginForm", register: "registerForm", forget: "forgetForm" };
    document.querySelectorAll(".xb-auth-tab").forEach(function (btn) {
      btn.classList.toggle("active", btn.getAttribute("data-auth-tab") === tab);
    });
    Object.keys(map).forEach(function (k) {
      var el = $(map[k]);
      if (el) el.classList.toggle("hidden", k !== tab);
    });
  }

  function switchPage(page) {
    state.page = page;
    document.querySelectorAll(".xb-nav-btn").forEach(function (btn) {
      btn.classList.toggle("active", btn.getAttribute("data-page") === page);
    });
    document.querySelectorAll(".xb-page").forEach(function (sec) {
      sec.classList.toggle("hidden", sec.getAttribute("data-page") !== page);
    });
  }

  function initBranding(cfg) {
    var data = cfg || {};
    var appName = data.app_name || boot.app_name || "XBoard";
    var appIcon = data.app_icon_url || boot.app_icon_url || "";
    var theme = data.theme_color || boot.theme_color || "";
    var crispId = data.crisp_website_id || boot.crisp_website_id || "";
    var packageName = data.app_package_name || boot.app_package_name || "";

    $("brandTitle").textContent = appName;
    $("brandMeta").textContent = packageName || t("brand_meta_default", "OpenClash XBoard Client");

    if (appIcon) {
      $("brandIcon").src = appIcon;
      $("brandIcon").classList.remove("hidden");
      $("brandDot").classList.add("hidden");
    } else {
      $("brandIcon").classList.add("hidden");
      $("brandDot").classList.remove("hidden");
    }

    if (theme && /^#[0-9a-fA-F]{3,6}$/.test(theme)) {
      $("xbApp").style.setProperty("--xb-primary", theme);
    }

    initCrisp(crispId);
  }

  function initCrisp(crispId) {
    if (!crispId) return;
    if (window.__OC_CRISP_INIT__) return;
    window.__OC_CRISP_INIT__ = true;
    window.$crisp = window.$crisp || [];
    window.CRISP_WEBSITE_ID = crispId;
    if (!document.querySelector('script[data-oc-crisp="1"]')) {
      var s = document.createElement("script");
      s.src = "https://client.crisp.chat/l.js";
      s.async = true;
      s.setAttribute("data-oc-crisp", "1");
      (document.head || document.body).appendChild(s);
    }
  }

  function renderHome() {
    var user = state.user || {};
    var stat = state.stat || {};
    var sub = state.subscribe || {};

    $("homeUserEmail").textContent = user.email || "-";
    $("homeUserBalance").textContent = user.balance != null ? String(user.balance) : "-";
    $("homeUserCommission").textContent = user.commission_balance != null ? String(user.commission_balance) : "-";
    $("homePlanName").textContent = sub.plan_id != null ? tf("plan_with_id", { plan_id: sub.plan_id }, "Plan #{plan_id}") : "-";

    var transferEnable = Number(sub.transfer_enable || 0);
    var used = Number(sub.u || 0) + Number(sub.d || 0);
    var remain = transferEnable > used ? transferEnable - used : 0;
    $("homeRemainTraffic").textContent = fmtTraffic(remain);
    $("homeExpiredAt").textContent = fmtDate(sub.expired_at || stat.expired_at || 0);

    if (!Array.isArray(state.notices) || !state.notices.length) {
      $("noticeList").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_notices", "No notices")) + "</div>";
      return;
    }

    $("noticeList").innerHTML = state.notices.slice(0, 6).map(function (n) {
      var title = escapeHtml(n.title || t("untitled_notice", "Untitled notice"));
      var content = escapeHtml(stripHtml(n.content || "")).slice(0, 180);
      return "<div class='xb-card' style='margin-bottom:8px;padding:10px;'><div style='font-weight:700;margin-bottom:4px;'>" + title + "</div><div class='xb-label'>" + content + "</div></div>";
    }).join("");
  }

  function planPeriods(plan) {
    var keys = [
      "month_price",
      "quarter_price",
      "half_year_price",
      "year_price",
      "two_year_price",
      "three_year_price",
      "onetime_price"
    ];
    var out = [];
    keys.forEach(function (k) {
      var val = plan[k];
      if (val !== undefined && val !== null && val !== "" && Number(val) > 0) {
        out.push({ key: k, label: t(PERIOD_LABEL_KEY[k], k), value: val });
      }
    });
    return out;
  }

  function renderPlans() {
    if (!Array.isArray(state.plans) || !state.plans.length) {
      $("plansList").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_plans_available", "No plans available")) + "</div>";
      return;
    }

    $("plansList").innerHTML = state.plans.map(function (p) {
      var periods = planPeriods(p);
      var options = periods.map(function (x) {
        return "<option value='" + escapeHtml(x.key) + "'>" + escapeHtml(x.label) + " / " + escapeHtml(String(x.value)) + "</option>";
      }).join("");
      var content = escapeHtml(stripHtml(p.content || "")).slice(0, 120);

      var actions = periods.length
        ? "<select class='xb-select' id='planPeriod_" + p.id + "'>" + options + "</select><button type='button' class='xb-btn' data-plan-buy='" + p.id + "'>" + escapeHtml(t("buy", "Buy")) + "</button>"
        : "<span class='xb-label'>" + escapeHtml(t("plan_no_period", "No billing period available")) + "</span>";

      return "<div class='xb-plan-item'>" +
        "<div class='xb-plan-name'>" + escapeHtml(p.name || tf("plan_with_id", { plan_id: p.id }, "Plan #{plan_id}")) + "</div>" +
        "<div class='xb-plan-meta'>" + escapeHtml(t("traffic_limit", "Traffic Limit")) + ": " + fmtTraffic(Number(p.transfer_enable || 0)) + "</div>" +
        "<div class='xb-plan-meta'>" + content + "</div>" +
        "<div class='xb-actions'><input class='xb-input' style='flex:1;' type='text' placeholder='" + escapeHtml(t("coupon_optional_placeholder", "Coupon Code (Optional)")) + "' id='coupon_" + p.id + "'><button type='button' class='xb-btn-ghost' data-coupon-check='" + p.id + "'>" + escapeHtml(t("coupon_verify", "Verify")) + "</button></div>" +
        "<div id='couponResult_" + p.id + "' class='hidden' style='font-size:12px;margin-top:4px;'></div>" +
        "<div class='xb-actions'>" + actions + "</div>" +
        "</div>";
    }).join("");

    document.querySelectorAll("[data-coupon-check]").forEach(function (btn) {
      btn.addEventListener("click", async function () {
        var planId = Number(btn.getAttribute("data-coupon-check"));
        var couponEl = $("coupon_" + planId);
        var code = couponEl ? couponEl.value.trim() : "";
        if (!code) return setNotice(t("coupon_code_required", "Please input coupon code"), "warn");

        btn.disabled = true;
        btn.textContent = t("coupon_verifying", "Verifying...");

        var result = await checkCoupon(code, planId);

        btn.disabled = false;
        btn.textContent = t("coupon_verify", "Verify");

        var resultEl = $("couponResult_" + planId);
        if (result && resultEl) {
          resultEl.classList.remove("hidden");
          var name = result.name || code;
          var val = result.value != null ? result.value : "";
          var unit = result.type === 1 ? "%" : t("currency_unit", "CNY");
          resultEl.innerHTML = "<span style='color:var(--xb-success);'>" + escapeHtml(tf("coupon_valid_summary", { name: name, value: val, unit: unit }, "Coupon valid: {name}, discount {value}{unit}")) + "</span>";
        } else if (resultEl) {
          resultEl.classList.add("hidden");
        }
      });
    });

    document.querySelectorAll("[data-plan-buy]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var id = Number(btn.getAttribute("data-plan-buy"));
        var periodEl = $("planPeriod_" + id);
        var period = periodEl ? periodEl.value : "";
        if (!period) return setNotice(t("plan_no_period", "No billing period available"), "warn");
        var couponEl = $("coupon_" + id);
        var couponCode = couponEl ? couponEl.value.trim() : "";
        buyPlan(id, period, btn, couponCode);
      });
    });
  }

  async function buyPlan(planId, period, btn, couponCode) {
    var text = btn.textContent;
    btn.disabled = true;
    btn.textContent = t("processing", "Processing...");

    try {
      var orderData = { plan_id: planId, period: period };
      if (couponCode) orderData.coupon_code = couponCode;

      var saveRes = await proxy("/api/v1/user/order/save", { method: "POST", data: orderData });
      var saveData = safeData(saveRes);
      var tradeNo = typeof saveData === "string" ? saveData : (saveData.trade_no || saveData.data || saveData.sn || "");
      if (!tradeNo) throw new Error(t("order_created_no_trade", "Order created but trade_no is missing"));

      var pmRes = await proxy("/api/v1/user/order/getPaymentMethod");
      var pmData = safeData(pmRes);
      var methods = Array.isArray(pmData) ? pmData : (Array.isArray(pmData.data) ? pmData.data : []);
      if (!methods.length) {
        setNotice(tf("order_created_complete_payment_panel", { trade_no: tradeNo }, "Order created. Complete payment on panel site. Order: {trade_no}"), "warn");
        return;
      }

      var methodId = methods[0].id;
      var coRes = await proxy("/api/v1/user/order/checkout", { method: "POST", data: { trade_no: tradeNo, method: methodId } });
      var coData = safeData(coRes);
      var link = typeof coData === "string" ? coData : (coData.data || coData.payment_url || coData.url || "");

      if (link && /^https?:\/\//.test(link)) {
        window.open(link, "_blank");
        setNotice(tf("payment_page_opened", { trade_no: tradeNo }, "Payment page opened. Order: {trade_no}"), "ok");
        startPaymentPolling(tradeNo);
      } else {
        setNotice(tf("order_created_finish_payment_in_orders", { trade_no: tradeNo }, "Order created. Please complete payment in order page. Order: {trade_no}"), "ok");
      }
    } catch (e) {
      setNotice(e.message || t("purchase_failed", "Purchase failed"), "err");
    } finally {
      btn.disabled = false;
      btn.textContent = text;
    }
  }

  function renderTickets() {
    if (!Array.isArray(state.tickets) || !state.tickets.length) {
      $("ticketsList").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_tickets", "No tickets")) + "</div>";
      return;
    }

    $("ticketsList").innerHTML = state.tickets.map(function (ticket) {
      var subject = escapeHtml(ticket.subject || tf("ticket_with_id", { ticket_id: ticket.id }, "Ticket #{ticket_id}"));
      var status = escapeHtml(String(ticket.status));
      var updated = escapeHtml(fmtDate(ticket.updated_at || ticket.created_at || 0));
      return "<div class='xb-ticket-item' data-ticket-id='" + ticket.id + "'><div style='font-weight:700;margin-bottom:4px;'>" + subject + "</div><div class='xb-ticket-meta'>" + escapeHtml(t("status", "Status")) + ": " + status + " / " + escapeHtml(t("updated_at", "Updated")) + ": " + updated + "</div></div>";
    }).join("");

    document.querySelectorAll("[data-ticket-id]").forEach(function (item) {
      item.addEventListener("click", function () {
        document.querySelectorAll("[data-ticket-id]").forEach(function (x) { x.classList.remove("active"); });
        item.classList.add("active");
        loadTicketDetail(Number(item.getAttribute("data-ticket-id")));
      });
    });
  }

  function renderTicketDetail() {
    var tkt = state.ticketDetail;
    if (!tkt) {
      $("ticketDetail").classList.remove("hidden");
      $("ticketDetail").textContent = t("select_ticket_left", "Please select a ticket from the left");
      $("ticketReplyBox").classList.add("hidden");
      return;
    }

    $("ticketDetail").classList.add("hidden");
    $("ticketReplyBox").classList.remove("hidden");

    var messages = Array.isArray(tkt.messages)
      ? tkt.messages
      : (tkt.message ? [{ message: tkt.message, created_at: tkt.updated_at || tkt.created_at, is_me: 0 }] : []);

    if (!messages.length) {
      $("ticketMessages").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_ticket_messages", "No ticket messages")) + "</div>";
      return;
    }

    $("ticketMessages").innerHTML = messages.map(function (m) {
      var role = m.is_me ? t("me", "Me") : t("support", "Support");
      return "<div class='xb-msg-item'><div class='xb-msg-head'><span>" + escapeHtml(role) + "</span><span>" + escapeHtml(fmtDate(m.created_at || 0)) + "</span></div><div>" + escapeHtml(m.message || "") + "</div></div>";
    }).join("");
  }

  function renderInvite() {
    var iv = state.invite || {};
    $("inviteBalance").textContent = iv.commission_balance != null ? String(iv.commission_balance) : "-";
    $("inviteCount").textContent = iv.invite_count != null ? String(iv.invite_count) : "-";

    var codes = Array.isArray(iv.codes) ? iv.codes : (Array.isArray(iv.data) ? iv.data : []);
    if (!codes.length) {
      $("inviteCodes").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_invite_codes", "No invite codes")) + "</div>";
    } else {
      $("inviteCodes").innerHTML = codes.map(function (c) {
        var val = typeof c === "string" ? c : (c.code || c.value || "");
        var s = escapeHtml(val);
        return "<div class='xb-row'><span class='xb-value'>" + s + "</span><button type='button' class='xb-btn-ghost' data-copy='" + s + "'>" + escapeHtml(t("copy", "Copy")) + "</button></div>";
      }).join("");

      document.querySelectorAll("[data-copy]").forEach(function (btn) {
        btn.addEventListener("click", function () {
          var text = btn.getAttribute("data-copy");
          navigator.clipboard.writeText(text).then(function () {
            setNotice(t("invite_code_copied", "Invite code copied"), "ok");
          }).catch(function () {
            setNotice(t("copy_failed_manual", "Copy failed, please copy manually"), "warn");
          });
        });
      });
    }

    if (!Array.isArray(state.inviteDetails) || !state.inviteDetails.length) {
      $("inviteDetails").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_invite_details", "No invite details")) + "</div>";
    } else {
      $("inviteDetails").innerHTML = state.inviteDetails.slice(0, 20).map(function (d) {
        var amount = d.get_amount != null ? d.get_amount : (d.commission || "-");
        return "<div class='xb-row'><span class='xb-label'>" + escapeHtml(fmtDate(d.created_at || 0)) + "</span><span class='xb-value'>" + escapeHtml(String(amount)) + "</span></div>";
      }).join("");
    }
  }

  async function loadConfig() {
    var cfg = await fetchJson(boot.config_url, { credentials: "same-origin" });
    // Use branding from boot (injected by Lua) instead of API response
    // to avoid exposing internal configuration like crisp_website_id, app_package_name, etc.
    initBranding(boot || {});
    state.baseUrl = cfg && cfg.base_url ? cfg.base_url : "";
    setApiState(!!state.baseUrl, state.baseUrl ? tf("api_endpoint", { url: state.baseUrl }, "API: {url}") : t("api_not_configured", "API Not Configured"));
  }

  async function loadGuestConfig() {
    try {
      var results = await Promise.all([
        proxy("/api/v1/guest/comm/config", { auth: false }).catch(function () { return {}; }),
        proxy("/api/v1/passport/comm/config", { auth: false }).catch(function () { return {}; })
      ]);
      state.guestConfig = safeData(results[0]);
      state.passportConfig = safeData(results[1]);
      applyGuestConfig();
    } catch (_e) {
      // ignore
    }
  }

  function applyGuestConfig() {
    var gc = state.guestConfig || {};
    var inviteBlock = $("regInviteBlock");
    var emailCodeBlock = $("regEmailCodeBlock");

    if (inviteBlock) {
      var inviteInput = inviteBlock.querySelector("input");
      var inviteLabel = inviteBlock.querySelector("label");
      if (gc.is_invite_force) {
        inviteBlock.classList.remove("hidden");
        if (inviteInput) inviteInput.required = true;
        if (inviteLabel) inviteLabel.textContent = t("invite_code_required", "Invite Code (Required)");
      } else {
        inviteBlock.classList.remove("hidden");
        if (inviteInput) inviteInput.required = false;
        if (inviteLabel) inviteLabel.textContent = t("invite_code_optional", "Invite Code (Optional)");
      }
    }

    if (emailCodeBlock) {
      var codeInput = emailCodeBlock.querySelector("input[name='email_code']");
      if (gc.is_email_verify) {
        emailCodeBlock.classList.remove("hidden");
        if (codeInput) codeInput.required = true;
      } else {
        emailCodeBlock.classList.add("hidden");
        if (codeInput) codeInput.required = false;
      }
    }
  }

  async function loadHomeBundle() {
    var out = await Promise.all([
      proxy("/api/v1/user/info"),
      proxy("/api/v1/user/getSubscribe"),
      proxy("/api/v1/user/getStat"),
      proxy("/api/v1/user/notice/fetch").catch(function () { return {}; })
    ]);
    state.user = safeData(out[0]);
    state.subscribe = safeData(out[1]);
    state.stat = safeData(out[2]);
    var notices = safeData(out[3]);
    state.notices = Array.isArray(notices) ? notices : (Array.isArray(notices.data) ? notices.data : []);
    renderHome();
  }

  async function loadPlans() {
    var res = await proxy("/api/v1/user/plan/fetch");
    var d = safeData(res);
    state.plans = Array.isArray(d) ? d : (Array.isArray(d.data) ? d.data : []);
    renderPlans();
  }

  async function loadTickets() {
    var res = await proxy("/api/v1/user/ticket/fetch");
    var d = safeData(res);
    state.tickets = Array.isArray(d) ? d : (Array.isArray(d.data) ? d.data : []);
    renderTickets();
  }

  async function loadTicketDetail(id) {
    if (!id) return;
    var res = await proxy("/api/v1/user/ticket/fetch", { query: { id: id } });
    var d = safeData(res);
    if (Array.isArray(d) && d.length) state.ticketDetail = d[0];
    else if (Array.isArray(d.data) && d.data.length) state.ticketDetail = d.data[0];
    else state.ticketDetail = d;
    renderTicketDetail();
  }

  async function loadInvite() {
    var out = await Promise.all([
      proxy("/api/v1/user/invite/fetch"),
      proxy("/api/v1/user/invite/details", { query: { limit: 20 } }).catch(function () { return {}; })
    ]);
    state.invite = safeData(out[0]);
    var d = safeData(out[1]);
    state.inviteDetails = Array.isArray(d) ? d : (Array.isArray(d.data) ? d.data : []);
    renderInvite();
  }

  async function loadOrders() {
    var res = await proxy("/api/v1/user/order/fetch");
    var d = safeData(res);
    state.orders = Array.isArray(d) ? d : (Array.isArray(d.data) ? d.data : []);
    renderOrders();
  }

  function renderOrders() {
    var filtered = state.orders;
    if (state.orderFilter >= 0) {
      filtered = state.orders.filter(function (o) { return toOrderStatus(o.status) === state.orderFilter; });
    }

    if (!filtered.length) {
      $("ordersList").innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_orders", "No orders")) + "</div>";
      return;
    }

    $("ordersList").innerHTML = filtered.map(function (o) {
      var status = toOrderStatus(o.status);
      var statusText = t(ORDER_STATUS[status], t("order_status_unknown", "Unknown"));
      var statusCls = ORDER_STATUS_CLS[status] || "";
      var planName = o.plan && o.plan.name ? o.plan.name : tf("plan_with_id", { plan_id: o.plan_id || "-" }, "Plan #{plan_id}");
      return "<div class='xb-order-item' data-order-no='" + escapeHtml(o.trade_no || "") + "'>" +
        "<div class='xb-row'><span class='xb-plan-name'>" + escapeHtml(planName) + "</span><span class='xb-order-status " + statusCls + "'>" + escapeHtml(statusText) + "</span></div>" +
        "<div class='xb-ticket-meta'>" + escapeHtml(t("order_no", "Order")) + ": " + escapeHtml(o.trade_no || "-") + " / " + escapeHtml(o.period || "-") + "</div>" +
        "<div class='xb-ticket-meta'>" + escapeHtml(t("amount", "Amount")) + ": " + escapeHtml(String(o.total_amount != null ? o.total_amount : "-")) + " / " + escapeHtml(t("created", "Created")) + ": " + escapeHtml(fmtDate(o.created_at || 0)) + "</div>" +
        "</div>";
    }).join("");

    document.querySelectorAll("[data-order-no]").forEach(function (item) {
      item.addEventListener("click", function () {
        loadOrderDetail(item.getAttribute("data-order-no"));
      });
    });
  }

  async function loadOrderDetail(tradeNo) {
    if (!tradeNo) return;
    try {
      var res = await proxy("/api/v1/user/order/detail", { query: { trade_no: tradeNo } });
      state.orderDetail = safeData(res);
      renderOrderDetail();
    } catch (e) {
      setNotice(e.message || t("get_order_detail_failed", "Failed to get order detail"), "err");
    }
  }

  function renderOrderDetail() {
    var o = state.orderDetail;
    if (!o || !o.trade_no) {
      $("orderDetailCard").classList.add("hidden");
      return;
    }

    $("orderDetailCard").classList.remove("hidden");
    var status = toOrderStatus(o.status);
    var statusText = t(ORDER_STATUS[status], t("order_status_unknown", "Unknown"));
    var statusCls = ORDER_STATUS_CLS[status] || "";
    var planName = o.plan && o.plan.name ? o.plan.name : tf("plan_with_id", { plan_id: o.plan_id || "-" }, "Plan #{plan_id}");

    var html = "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("order_no", "Order")) + "</span><span class='xb-value'>" + escapeHtml(o.trade_no) + "</span></div>" +
      "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("plan", "Plan")) + "</span><span class='xb-value'>" + escapeHtml(planName) + "</span></div>" +
      "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("period", "Period")) + "</span><span class='xb-value'>" + escapeHtml(o.period || "-") + "</span></div>" +
      "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("amount", "Amount")) + "</span><span class='xb-value'>" + escapeHtml(String(o.total_amount != null ? o.total_amount : "-")) + "</span></div>" +
      (o.discount_amount ? "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("discount", "Discount")) + "</span><span class='xb-value'>-" + escapeHtml(String(o.discount_amount)) + "</span></div>" : "") +
      "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("status", "Status")) + "</span><span class='xb-order-status " + statusCls + "'>" + escapeHtml(statusText) + "</span></div>" +
      "<div class='xb-row'><span class='xb-label'>" + escapeHtml(t("created", "Created")) + "</span><span class='xb-value'>" + escapeHtml(fmtDate(o.created_at || 0)) + "</span></div>" +
      "<div class='xb-actions'>";

    if (status === 0) {
      html += "<button type='button' class='xb-btn' id='payOrderBtn'>" + escapeHtml(t("pay_now", "Pay Now")) + "</button>" +
        "<button type='button' class='xb-btn-ghost' id='cancelOrderBtn'>" + escapeHtml(t("cancel_order", "Cancel Order")) + "</button>";
    }

    html += "</div>";
    $("orderDetailContent").innerHTML = html;

    var payBtn = $("payOrderBtn");
    if (payBtn) payBtn.addEventListener("click", function () { payOrder(o.trade_no); });

    var cancelBtn = $("cancelOrderBtn");
    if (cancelBtn) cancelBtn.addEventListener("click", function () { cancelOrder(o.trade_no); });
  }

  async function payOrder(tradeNo) {
    try {
      var pmRes = await proxy("/api/v1/user/order/getPaymentMethod");
      var pmData = safeData(pmRes);
      var methods = Array.isArray(pmData) ? pmData : (Array.isArray(pmData.data) ? pmData.data : []);
      if (!methods.length) {
        setNotice(t("no_payment_method", "No payment method available, complete payment on panel site"), "warn");
        return;
      }

      var methodId = methods[0].id;
      var coRes = await proxy("/api/v1/user/order/checkout", { method: "POST", data: { trade_no: tradeNo, method: methodId } });
      var coData = safeData(coRes);
      var link = typeof coData === "string" ? coData : (coData.data || coData.payment_url || coData.url || "");
      if (link && /^https?:\/\//.test(link)) {
        window.open(link, "_blank");
        setNotice(t("payment_opened", "Payment page opened"), "ok");
        startPaymentPolling(tradeNo);
      } else {
        setNotice(t("cannot_get_payment_link", "Cannot get payment link, complete payment on panel site"), "warn");
      }
    } catch (e) {
      setNotice(e.message || t("pay_failed", "Payment failed"), "err");
    }
  }

  async function cancelOrder(tradeNo) {
    if (!confirm(tf("confirm_cancel_order", { trade_no: tradeNo }, "Are you sure to cancel order {trade_no}?"))) return;
    try {
      await proxy("/api/v1/user/order/cancel", { method: "POST", data: { trade_no: tradeNo } });
      setNotice(t("order_cancelled", "Order cancelled"), "ok");
      state.orderDetail = null;
      renderOrderDetail();
      await loadOrders();
    } catch (e) {
      setNotice(e.message || t("cancel_order_failed", "Cancel order failed"), "err");
    }
  }

  async function checkOrderStatus(tradeNo) {
    try {
      var res = await proxy("/api/v1/user/order/check", { query: { trade_no: tradeNo } });
      return safeData(res);
    } catch (_e) {
      return null;
    }
  }

  function startPaymentPolling(tradeNo) {
    stopPaymentPolling();
    var count = 0;
    var maxCount = 100;

    state.paymentPolling = setInterval(function () {
      count += 1;
      if (count >= maxCount) {
        stopPaymentPolling();
        setNotice(t("payment_check_timeout", "Payment check timeout, please refresh orders manually"), "warn");
        return;
      }

      checkOrderStatus(tradeNo).then(function (data) {
        var status = data ? toOrderStatus(data.status) : -1;
        if (status === 2 || status === 3) {
          stopPaymentPolling();
          if (status === 2) setNotice(t("payment_succeeded", "Payment succeeded"), "ok");
          loadOrders().catch(function () {});
          loadHomeBundle().catch(function () {});
        }
      });
    }, 3000);
  }

  function stopPaymentPolling() {
    if (state.paymentPolling) {
      clearInterval(state.paymentPolling);
      state.paymentPolling = null;
    }
  }

  async function loadCommConfig() {
    try {
      var res = await proxy("/api/v1/user/comm/config");
      state.commConfig = safeData(res);
      renderCommWithdraw();
    } catch (_e) {
      state.commConfig = null;
      renderCommWithdraw();
    }
  }

  function renderCommWithdraw() {
    var cfg = state.commConfig || {};
    var container = $("withdrawSection");
    if (!container) return;

    var methods = cfg.withdraw_methods || [];
    if (!methods.length) {
      container.classList.add("hidden");
      return;
    }

    container.classList.remove("hidden");
    var selectEl = $("withdrawMethodSelect");
    if (selectEl) {
      selectEl.innerHTML = methods.map(function (m) {
        return "<option value='" + escapeHtml(m) + "'>" + escapeHtml(m) + "</option>";
      }).join("");
    }
  }

  async function submitWithdraw() {
    var methodEl = $("withdrawMethodSelect");
    var accountEl = $("withdrawAccount");
    var method = methodEl ? methodEl.value : "";
    var account = accountEl ? accountEl.value.trim() : "";

    if (!method) return setNotice(t("select_withdraw_method", "Please select withdraw method"), "warn");
    if (!account) return setNotice(t("input_withdraw_account", "Please input withdraw account"), "warn");

    try {
      await proxy("/api/v1/user/ticket/withdraw", { method: "POST", data: { withdraw_method: method, withdraw_account: account } });
      setNotice(t("withdraw_submitted", "Withdraw request submitted"), "ok");
      if (accountEl) accountEl.value = "";
      await loadInvite();
    } catch (e) {
      setNotice(e.message || t("withdraw_failed", "Withdraw request failed"), "err");
    }
  }

  async function loadTrafficLogs(offset) {
    offset = offset || 0;
    var limit = 20;
    var res = await proxy("/api/v1/user/stat/getTrafficLog", { query: { offset: offset, limit: limit } });
    var d = safeData(res);
    var logs = Array.isArray(d) ? d : (Array.isArray(d.data) ? d.data : []);

    if (offset === 0) state.trafficLogs = logs;
    else state.trafficLogs = state.trafficLogs.concat(logs);

    state.trafficTotal = d.total || state.trafficLogs.length;
    renderTrafficLogs();
  }

  function renderTrafficLogs() {
    var container = $("trafficLogList");
    if (!container) return;

    if (!state.trafficLogs.length) {
      container.innerHTML = "<div class='xb-empty'>" + escapeHtml(t("no_traffic_logs", "No traffic logs")) + "</div>";
      var more = $("trafficLogMore");
      if (more) more.style.display = "none";
      return;
    }

    var html = "<table class='xb-traffic-table'><thead><tr><th>" + escapeHtml(t("table_date", "Date")) + "</th><th>" + escapeHtml(t("table_upload", "Upload")) + "</th><th>" + escapeHtml(t("table_download", "Download")) + "</th><th>" + escapeHtml(t("table_total", "Total")) + "</th></tr></thead><tbody>";
    state.trafficLogs.forEach(function (log) {
      var u = Number(log.u || 0);
      var d = Number(log.d || 0);
      html += "<tr><td>" + escapeHtml(fmtDate(log.record_at || log.created_at || 0)) + "</td><td>" + escapeHtml(fmtTraffic(u)) + "</td><td>" + escapeHtml(fmtTraffic(d)) + "</td><td>" + escapeHtml(fmtTraffic(u + d)) + "</td></tr>";
    });
    html += "</tbody></table>";
    container.innerHTML = html;

    var moreEl = $("trafficLogMore");
    if (moreEl) moreEl.style.display = state.trafficLogs.length < state.trafficTotal ? "" : "none";
  }

  async function loadGuestPlans() {
    try {
      var res = await proxy("/api/v1/guest/plan/fetch", { auth: false });
      var d = safeData(res);
      state.guestPlans = Array.isArray(d) ? d : (Array.isArray(d.data) ? d.data : []);
      renderGuestPlans();
    } catch (_e) {
      state.guestPlans = [];
      renderGuestPlans();
    }
  }

  function renderGuestPlans() {
    var container = $("guestPlansList");
    var section = $("guestPlansSection");
    if (!container || !section) return;

    if (!state.guestPlans.length) {
      container.innerHTML = "";
      section.classList.add("hidden");
      return;
    }

    section.classList.remove("hidden");
    container.innerHTML = state.guestPlans.map(function (p) {
      var periods = planPeriods(p);
      var priceStr = periods.length
        ? periods.map(function (x) { return escapeHtml(x.label) + " " + escapeHtml(String(x.value)); }).join(" / ")
        : t("no_pricing", "No pricing");
      var content = escapeHtml(stripHtml(p.content || "")).slice(0, 120);
      return "<div class='xb-plan-item'><div class='xb-plan-name'>" + escapeHtml(p.name || tf("plan_with_id", { plan_id: p.id }, "Plan #{plan_id}")) + "</div><div class='xb-plan-meta'>" + escapeHtml(t("guest_plan_traffic", "Traffic")) + ": " + escapeHtml(fmtTraffic(Number(p.transfer_enable || 0))) + "</div><div class='xb-plan-meta'>" + content + "</div><div class='xb-plan-meta' style='font-weight:600;color:var(--xb-primary);'>" + priceStr + "</div></div>";
    }).join("");
  }

  async function checkCoupon(code, planId) {
    try {
      var res = await proxy("/api/v1/user/coupon/check", { method: "POST", data: { code: code, plan_id: planId } });
      return safeData(res);
    } catch (e) {
      setNotice(e.message || t("coupon_validation_failed", "Coupon validation failed"), "err");
      return null;
    }
  }

  async function bootstrapPanel() {
    showAuth(false);
    switchPage(state.page || "home");
    await loadHomeBundle();
    await Promise.all([
      loadPlans(),
      loadOrders(),
      loadTickets(),
      loadInvite(),
      loadTrafficLogs(0).catch(function () {}),
      loadCommConfig()
    ]);
  }

  function loginToken(res) {
    var d = safeData(res);
    return d.auth_data || d.token || "";
  }

  async function sendEmailCode(email) {
    email = String(email || "").trim();
    if (!email) return setNotice(t("input_email_first", "Please input email first"), "warn");
    try {
      await proxy("/api/v1/passport/comm/sendEmailVerify", { method: "POST", auth: false, data: { email: email } });
      setNotice(t("verification_code_sent", "Verification code sent, please check your email"), "ok");
    } catch (e) {
      setNotice(e.message || t("send_code_failed", "Send code failed"), "err");
    }
  }

  function bindEvents() {
    document.querySelectorAll(".xb-auth-tab").forEach(function (btn) {
      btn.addEventListener("click", function () { switchAuthTab(btn.getAttribute("data-auth-tab")); });
    });

    document.querySelectorAll(".xb-nav-btn").forEach(function (btn) {
      btn.addEventListener("click", function () { switchPage(btn.getAttribute("data-page")); });
    });

    $("loginForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      var form = new FormData(e.target);
      try {
        var res = await proxy("/api/v1/passport/auth/login", { method: "POST", auth: false, data: { email: String(form.get("email") || ""), password: String(form.get("password") || "") } });
        var token = loginToken(res);
        if (!token) throw new Error(t("login_no_token", "Login succeeded but token is missing"));
        state.token = token;
        localStorage.setItem(TOKEN_KEY, token);
        setNotice(t("login_success_loading", "Login succeeded, loading dashboard..."), "ok");
        await bootstrapPanel();
      } catch (err) {
        setNotice(err.message || t("login_failed", "Login failed"), "err");
      }
    });

    $("registerForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      var form = new FormData(e.target);
      try {
        await proxy("/api/v1/passport/auth/register", { method: "POST", auth: false, data: { email: String(form.get("email") || ""), password: String(form.get("password") || ""), invite_code: String(form.get("invite_code") || ""), email_code: String(form.get("email_code") || "") } });
        setNotice(t("register_success_back_login", "Register succeeded, please login"), "ok");
        switchAuthTab("login");
      } catch (err) {
        setNotice(err.message || t("register_failed", "Register failed"), "err");
      }
    });

    $("forgetForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      var form = new FormData(e.target);
      try {
        await proxy("/api/v1/passport/auth/forget", { method: "POST", auth: false, data: { email: String(form.get("email") || ""), email_code: String(form.get("email_code") || ""), password: String(form.get("password") || "") } });
        setNotice(t("reset_password_success_login", "Password reset succeeded, please login"), "ok");
        switchAuthTab("login");
      } catch (err) {
        setNotice(err.message || t("reset_password_failed", "Password reset failed"), "err");
      }
    });

    $("sendRegisterCodeBtn").addEventListener("click", function () {
      sendEmailCode($("registerForm").querySelector("input[name='email']").value);
    });

    $("sendForgetCodeBtn").addEventListener("click", function () {
      sendEmailCode($("forgetForm").querySelector("input[name='email']").value);
    });

    $("refreshHomeBtn").addEventListener("click", async function () {
      try { await loadHomeBundle(); setNotice(t("home_refreshed", "Home data refreshed"), "ok"); } catch (e) { setNotice(e.message || t("refresh_failed", "Refresh failed"), "err"); }
    });

    $("refreshPlansBtn").addEventListener("click", async function () {
      try { await loadPlans(); setNotice(t("plans_refreshed", "Plans refreshed"), "ok"); } catch (e) { setNotice(e.message || t("refresh_failed", "Refresh failed"), "err"); }
    });

    $("refreshTicketsBtn").addEventListener("click", async function () {
      try { state.ticketDetail = null; renderTicketDetail(); await loadTickets(); setNotice(t("tickets_refreshed", "Tickets refreshed"), "ok"); } catch (e) { setNotice(e.message || t("refresh_failed", "Refresh failed"), "err"); }
    });

    $("refreshInviteBtn").addEventListener("click", async function () {
      try { await loadInvite(); setNotice(t("invite_refreshed", "Invite data refreshed"), "ok"); } catch (e) { setNotice(e.message || t("refresh_failed", "Refresh failed"), "err"); }
    });

    $("refreshOrdersBtn").addEventListener("click", async function () {
      try { state.orderDetail = null; renderOrderDetail(); await loadOrders(); setNotice(t("orders_refreshed", "Orders refreshed"), "ok"); } catch (e) { setNotice(e.message || t("refresh_failed", "Refresh failed"), "err"); }
    });

    document.querySelectorAll("[data-order-filter]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        state.orderFilter = Number(btn.getAttribute("data-order-filter"));
        document.querySelectorAll("[data-order-filter]").forEach(function (b) {
          b.classList.toggle("active", b.getAttribute("data-order-filter") === btn.getAttribute("data-order-filter"));
        });
        renderOrders();
      });
    });

    $("loadMoreTrafficBtn").addEventListener("click", async function () {
      try { await loadTrafficLogs(state.trafficLogs.length); } catch (e) { setNotice(e.message || t("load_failed", "Load failed"), "err"); }
    });

    $("submitWithdrawBtn").addEventListener("click", function () {
      submitWithdraw();
    });

    $("copySubBtn").addEventListener("click", function () {
      var url = (state.subscribe || {}).subscribe_url || "";
      if (!url) return setNotice(t("no_subscription_link", "No subscription link for current account"), "warn");
      navigator.clipboard.writeText(url).then(function () {
        setNotice(t("subscription_copied", "Subscription link copied"), "ok");
      }).catch(function () {
        setNotice(t("copy_failed_manual", "Copy failed, please copy manually"), "warn");
      });
    });

    $("resetSubBtn").addEventListener("click", async function () {
      try { await proxy("/api/v1/user/resetSecurity"); await loadHomeBundle(); setNotice(t("subscription_reset", "Subscription link reset"), "ok"); } catch (e) { setNotice(e.message || t("subscription_reset_failed", "Reset failed"), "err"); }
    });

    $("createTicketForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      var f = new FormData(e.target);
      try {
        await proxy("/api/v1/user/ticket/save", { method: "POST", data: { subject: String(f.get("subject") || ""), level: Number(f.get("level") || 0), message: String(f.get("message") || "") } });
        e.target.reset();
        await loadTickets();
        setNotice(t("ticket_created", "Ticket created"), "ok");
      } catch (err) {
        setNotice(err.message || t("create_ticket_failed", "Create ticket failed"), "err");
      }
    });

    $("ticketReplyForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      if (!state.ticketDetail || !state.ticketDetail.id) return setNotice(t("select_ticket_first", "Please select ticket first"), "warn");
      var f = new FormData(e.target);
      try {
        await proxy("/api/v1/user/ticket/reply", { method: "POST", data: { id: Number(state.ticketDetail.id), message: String(f.get("message") || "") } });
        e.target.reset();
        await loadTicketDetail(Number(state.ticketDetail.id));
        setNotice(t("reply_sent", "Reply sent"), "ok");
      } catch (err) {
        setNotice(err.message || t("reply_failed", "Reply failed"), "err");
      }
    });

    $("closeTicketBtn").addEventListener("click", async function () {
      if (!state.ticketDetail || !state.ticketDetail.id) return setNotice(t("select_ticket_first", "Please select ticket first"), "warn");
      try {
        await proxy("/api/v1/user/ticket/close", { method: "POST", data: { id: Number(state.ticketDetail.id) } });
        await loadTickets();
        await loadTicketDetail(Number(state.ticketDetail.id));
        setNotice(t("ticket_closed", "Ticket closed"), "ok");
      } catch (err) {
        setNotice(err.message || t("close_ticket_failed", "Close ticket failed"), "err");
      }
    });

    $("createInviteBtn").addEventListener("click", async function () {
      try { await proxy("/api/v1/user/invite/save"); await loadInvite(); setNotice(t("invite_code_created", "Invite code created"), "ok"); } catch (e) { setNotice(e.message || t("invite_code_create_failed", "Create invite code failed"), "err"); }
    });

    $("transferInviteBtn").addEventListener("click", async function () {
      var amount = prompt(t("transfer_amount_prompt", "Please input transfer amount"), "");
      if (amount === null) return;
      var num = Number(amount);
      if (!Number.isFinite(num) || num <= 0) return setNotice(t("input_valid_amount", "Please input a valid amount"), "warn");
      try {
        await proxy("/api/v1/user/transfer", { method: "POST", data: { transfer_amount: num } });
        await Promise.all([loadInvite(), loadHomeBundle()]);
        setNotice(t("commission_transferred", "Commission transferred"), "ok");
      } catch (err) {
        setNotice(err.message || t("transfer_failed", "Transfer failed"), "err");
      }
    });

    $("updateUserForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      var f = new FormData(e.target);
      try {
        await proxy("/api/v1/user/update", { method: "POST", data: { telegram_id: String(f.get("telegram_id") || ""), remind_expire: String(f.get("remind_expire") || ""), remind_traffic: String(f.get("remind_traffic") || "") } });
        await loadHomeBundle();
        setNotice(t("account_settings_saved", "Account settings saved"), "ok");
      } catch (err) {
        setNotice(err.message || t("save_failed", "Save failed"), "err");
      }
    });

    $("changePasswordForm").addEventListener("submit", async function (e) {
      e.preventDefault();
      var f = new FormData(e.target);
      try {
        await proxy("/api/v1/user/changePassword", { method: "POST", data: { old_password: String(f.get("old_password") || ""), new_password: String(f.get("new_password") || "") } });
        e.target.reset();
        setNotice(t("password_changed", "Password changed"), "ok");
      } catch (err) {
        setNotice(err.message || t("change_password_failed", "Change password failed"), "err");
      }
    });

    $("logoutBtn").addEventListener("click", async function () {
      try {
        // v2board does not have a logout API, just clear local state
      } finally {
        stopPaymentPolling();
        state.token = "";
        localStorage.removeItem(TOKEN_KEY);
        state.user = null;
        state.subscribe = null;
        state.stat = null;
        state.notices = [];
        state.plans = [];
        state.tickets = [];
        state.ticketDetail = null;
        state.invite = null;
        state.inviteDetails = [];
        state.orders = [];
        state.orderDetail = null;
        state.orderFilter = -1;
        state.trafficLogs = [];
        state.trafficTotal = 0;
        state.commConfig = null;
        state.guestPlans = [];
        state.guestConfig = null;
        state.passportConfig = null;

        renderGuestPlans();
        applyGuestConfig();
        renderOrders();
        renderOrderDetail();
        renderTrafficLogs();
        renderCommWithdraw();

        document.querySelectorAll("[data-order-filter]").forEach(function (b) {
          b.classList.toggle("active", b.getAttribute("data-order-filter") === "-1");
        });

        showAuth(true);
        switchAuthTab("login");
        setNotice(t("logged_out", "Logged out"), "ok");
      }
    });
  }

  async function init() {
    bindEvents();
    showAuth(true);
    switchAuthTab("login");
    setNotice(t("initializing", "Initializing XBoard client..."), "info");

    await loadConfig();

    if (!state.baseUrl) {
      setNotice(t("base_not_configured", "API_BASE_URL / API_TEXT_DOMAIN not configured. Configure GitHub Actions secrets."), "warn");
      return;
    }

    await Promise.all([
      loadGuestConfig(),
      loadGuestPlans()
    ]);

    if (!state.token) {
      setNotice(t("login_first", "Please login XBoard account first"), "info");
      return;
    }

    try {
      // v2board uses checkLogin instead of auth/check
      var checkRes = await proxy("/api/v1/user/checkLogin");
      var checkData = safeData(checkRes);
      if (checkData && checkData.is_login) {
        await bootstrapPanel();
        setNotice(t("session_restored", "Session restored"), "ok");
      } else {
        throw new Error("Not logged in");
      }
    } catch (_e) {
      stopPaymentPolling();
      state.token = "";
      localStorage.removeItem(TOKEN_KEY);
      showAuth(true);
      switchAuthTab("login");
      setNotice(t("session_expired_login_again", "Session expired, please login again"), "warn");
    }
  }

  init().catch(function (e) {
    setNotice(t("init_failed", "Initialization failed") + " " + (e && e.message ? e.message : ""), "err");
  });
})();
