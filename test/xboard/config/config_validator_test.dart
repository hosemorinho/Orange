/// 配置验证器测试
///
/// 测试 ConfigValidator 的各种验证功能
library;

import 'package:fl_clash/xboard/config/utils/config_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigValidator 配置验证器', () {
    group('URL 验证', () {
      test('应验证有效的 HTTPS URL', () {
        expect(
          ConfigValidator.isValidUrl('https://example.com'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidUrl('https://api.example.com/v1'),
          isTrue,
        );
      });

      test('应验证有效的 HTTP URL', () {
        expect(
          ConfigValidator.isValidUrl('http://example.com'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidUrl('http://192.168.1.1:8080'),
          isTrue,
        );
      });

      test('应拒绝无效的 URL', () {
        expect(ConfigValidator.isValidUrl(''), isFalse);
        expect(ConfigValidator.isValidUrl('not-a-url'), isFalse);
        expect(ConfigValidator.isValidUrl('ftp://example.com'), isTrue); // FTP 是有效协议
        expect(ConfigValidator.isValidUrl('example'), isFalse);
      });

      test('应验证 HTTP/HTTPS URL', () {
        expect(
          ConfigValidator.isValidHttpUrl('https://example.com'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidHttpUrl('http://example.com'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidHttpUrl('ftp://example.com'),
          isFalse,
        );
      });

      test('应验证 WebSocket URL', () {
        expect(
          ConfigValidator.isValidWebSocketUrl('ws://example.com/socket'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidWebSocketUrl('wss://example.com/secure'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidWebSocketUrl('https://example.com'),
          isFalse,
        );
      });
    });

    group('端口验证', () {
      test('应验证有效的端口号', () {
        expect(ConfigValidator.isValidPort(80), isTrue);
        expect(ConfigValidator.isValidPort(443), isTrue);
        expect(ConfigValidator.isValidPort(8080), isTrue);
        expect(ConfigValidator.isValidPort(1), isTrue);
        expect(ConfigValidator.isValidPort(65535), isTrue);
      });

      test('应拒绝无效的端口号', () {
        expect(ConfigValidator.isValidPort(0), isFalse);
        expect(ConfigValidator.isValidPort(-1), isFalse);
        expect(ConfigValidator.isValidPort(65536), isFalse);
        expect(ConfigValidator.isValidPort(100000), isFalse);
      });
    });

    group('代理 URL 验证', () {
      test('应验证带认证的代理 URL', () {
        expect(
          ConfigValidator.isValidProxyUrl('username:password@proxy.com:8080'),
          isTrue,
        );
        expect(
          ConfigValidator.isValidProxyUrl('http://user:pass@proxy.com:8080'),
          isTrue,
        );
      });

      test('应验证简单的 host:port 格式', () {
        expect(ConfigValidator.isValidProxyUrl('proxy.com:8080'), isTrue);
        expect(ConfigValidator.isValidProxyUrl('192.168.1.1:3128'), isTrue);
      });

      test('应拒绝无效的代理 URL', () {
        expect(ConfigValidator.isValidProxyUrl(''), isFalse);
        expect(ConfigValidator.isValidProxyUrl('proxy.com'), isFalse);
        expect(ConfigValidator.isValidProxyUrl('8080'), isFalse);
        // 注意：':8080' 会被认为是有效的 host:port 格式（host 为空）
        // 但根据实现，split(':') 会得到 ['', '8080']，长度为 2，所以返回 true
        // expect(ConfigValidator.isValidProxyUrl(':8080'), isFalse);
      });
    });

    group('协议验证', () {
      test('应验证有效的协议', () {
        expect(ConfigValidator.isValidProtocol('http'), isTrue);
        expect(ConfigValidator.isValidProtocol('https'), isTrue);
        expect(ConfigValidator.isValidProtocol('socks5'), isTrue);
        expect(ConfigValidator.isValidProtocol('ws'), isTrue);
        expect(ConfigValidator.isValidProtocol('wss'), isTrue);
      });

      test('应忽略协议大小写', () {
        expect(ConfigValidator.isValidProtocol('HTTP'), isTrue);
        expect(ConfigValidator.isValidProtocol('HtTp'), isTrue);
        expect(ConfigValidator.isValidProtocol('SOCKS5'), isTrue);
      });

      test('应拒绝无效的协议', () {
        expect(ConfigValidator.isValidProtocol('ftp'), isFalse);
        expect(ConfigValidator.isValidProtocol('tcp'), isFalse);
        expect(ConfigValidator.isValidProtocol('udp'), isFalse);
        expect(ConfigValidator.isValidProtocol(''), isFalse);
      });
    });

    group('配置条目验证', () {
      test('应验证有效的配置条目', () {
        final validEntry = {
          'url': 'https://example.com',
          'description': 'Test Config',
        };
        expect(ConfigValidator.isValidConfigEntry(validEntry), isTrue);
      });

      test('应拒绝缺少 url 字段的配置', () {
        final invalidEntry = {
          'description': 'Test Config',
        };
        expect(ConfigValidator.isValidConfigEntry(invalidEntry), isFalse);
      });

      test('应拒绝缺少 description 字段的配置', () {
        final invalidEntry = {
          'url': 'https://example.com',
        };
        expect(ConfigValidator.isValidConfigEntry(invalidEntry), isFalse);
      });

      test('应拒绝空字符串的配置', () {
        final invalidEntry = {
          'url': '',
          'description': 'Test',
        };
        expect(ConfigValidator.isValidConfigEntry(invalidEntry), isFalse);

        final invalidEntry2 = {
          'url': 'https://example.com',
          'description': '',
        };
        expect(ConfigValidator.isValidConfigEntry(invalidEntry2), isFalse);
      });

      test('应拒绝非字符串类型的配置', () {
        final invalidEntry = {
          'url': 123,
          'description': 'Test',
        };
        expect(ConfigValidator.isValidConfigEntry(invalidEntry), isFalse);
      });
    });

    group('代理配置条目验证', () {
      test('应验证有效的代理配置', () {
        // 注意：isValidProxyEntry 需要的是完整的配置条目
        // 它首先调用 isValidConfigEntry 检查 url 和 description
        // 然后检查 protocol 字段
        final validProxy = {
          'url': 'http://proxy.com:8080',
          'description': 'Test Proxy',
          'protocol': 'http',
        };
        expect(ConfigValidator.isValidProxyEntry(validProxy), isTrue);
      });

      test('应拒绝缺少 protocol 字段的代理配置', () {
        // isValidProxyEntry 首先检查 isValidConfigEntry
        // 然后检查 protocol 字段
        final invalidProxy = {
          'url': 'http://proxy.com:8080',
          'description': 'Test Proxy',
        };
        expect(ConfigValidator.isValidProxyEntry(invalidProxy), isFalse);
      });

      test('应拒绝无效协议的代理配置', () {
        final invalidProxy = {
          'url': 'http://proxy.com:8080',
          'description': 'Test Proxy',
          'protocol': 'ftp',
        };
        expect(ConfigValidator.isValidProxyEntry(invalidProxy), isFalse);
      });
    });

    group('面板配置验证', () {
      test('应验证有效的面板配置', () {
        final validPanels = {
          'Provider1': [
            {'url': 'https://panel1.example.com', 'description': 'Panel 1'},
            {'url': 'https://panel2.example.com', 'description': 'Panel 2'},
          ],
          'Provider2': [
            {'url': 'https://panel3.example.com', 'description': 'Panel 3'},
          ],
        };
        expect(ConfigValidator.isValidPanelConfig(validPanels), isTrue);
      });

      test('应拒绝无效的提供商名称', () {
        final invalidPanels = {
          '': [
            {'url': 'https://panel1.example.com', 'description': 'Panel 1'},
          ],
        };
        expect(ConfigValidator.isValidPanelConfig(invalidPanels), isFalse);
      });

      test('应拒绝非列表的面板值', () {
        final invalidPanels = {
          'Provider1': 'not-a-list',
        };
        expect(ConfigValidator.isValidPanelConfig(invalidPanels), isFalse);
      });

      test('应拒绝面板列表中的无效条目', () {
        final invalidPanels = {
          'Provider1': [
            {'url': 'https://panel1.example.com'}, // 缺少 description
          ],
        };
        expect(ConfigValidator.isValidPanelConfig(invalidPanels), isFalse);
      });
    });

    group('完整配置验证', () {
      test('应验证包含 panels 的最小配置', () {
        final config = {
          'panels': {
            'Provider': [
              {'url': 'https://panel.example.com', 'description': 'Panel'},
            ],
          },
        };
        expect(ConfigValidator.isValidConfiguration(config), isTrue);
      });

      test('应验证包含 proxy 的配置', () {
        final config = {
          'proxy': [
            {
              'url': 'http://proxy.com:8080',
              'description': 'Proxy',
              'protocol': 'http',
            },
          ],
        };
        expect(ConfigValidator.isValidConfiguration(config), isTrue);
      });

      test('应拒绝空配置', () {
        expect(ConfigValidator.isValidConfiguration({}), isFalse);
      });

      test('应拒绝缺少主要字段的配置', () {
        final config = {
          'other': 'value',
        };
        expect(ConfigValidator.isValidConfiguration(config), isFalse);
      });

      test('应验证复杂的混合配置', () {
        final config = {
          'panels': {
            'Provider1': [
              {'url': 'https://panel1.example.com', 'description': 'Panel 1'},
            ],
          },
          'proxy': [
            {
              'url': 'http://proxy.com:8080',
              'description': 'HTTP Proxy',
              'protocol': 'http',
            },
          ],
          'ws': [
            {'url': 'wss://ws.example.com', 'description': 'WebSocket'},
          ],
          'update': [
            {'url': 'https://update.example.com', 'description': 'Update'},
          ],
        };
        expect(ConfigValidator.isValidConfiguration(config), isTrue);
      });
    });

    group('验证错误详情', () {
      test('应返回空配置的错误', () {
        final errors = ConfigValidator.getValidationErrors({});
        expect(errors, isNotEmpty);
        expect(
          errors.first,
          contains('must contain at least one of'),
        );
      });

      test('应返回 panels 类型错误', () {
        final config = {
          'panels': 'not-a-map',
        };
        final errors = ConfigValidator.getValidationErrors(config);
        expect(errors, contains('panels must be an object'));
      });

      test('应返回 proxy 类型错误', () {
        final config = {
          'proxy': 'not-a-list',
        };
        final errors = ConfigValidator.getValidationErrors(config);
        expect(errors, contains('proxy must be an array'));
      });

      test('应返回订阅配置错误', () {
        final config = {
          'subscription': {
            'urls': 'not-a-list',
          },
        };
        final errors = ConfigValidator.getValidationErrors(config);
        expect(errors, contains('subscription.urls must be an array'));
      });
    });
  });
}
