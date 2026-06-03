PREFIX ?= /opt/subnet-calc-app

.PHONY: all install uninstall deploy-local deploy-remote clean verify

all:
	@echo "子网掩码计算器 - Build targets:"
	@echo "  make deploy-local   - 部署到本机 Nginx"
	@echo "  make deploy-remote  - 部署到远程服务器"
	@echo "  make verify         - 验证部署"
	@echo "  make clean          - 清理"

install:
	install -d $(PREFIX)
	cp index.html $(PREFIX)/
	cp subnet-calc.py $(PREFIX)/
	chmod +x $(PREFIX)/subnet-calc.py
	@echo "✅ 安装完成: $(PREFIX)"

uninstall:
	rm -rf $(PREFIX)

# 部署到 10.211.55.6 (本地服务器)
deploy-local:
	install -d /usr/share/nginx/html/subnet-calc/
	cp index.html /usr/share/nginx/html/subnet-calc/
	@echo "✅ 已部署到本机: http://10.211.55.6/subnet-calc/"

# 部署到 101.77 (远程服务器)
deploy-remote:
	scp index.html root@10.211.55.101:/usr/share/nginx/html/subnet-calc/
	@echo "✅ 已部署到 101.77"

verify:
	@echo "检查部署..."
	curl -s -o /dev/null -w "%{http_code}" http://10.211.55.6/subnet-calc/ 2>/dev/null || echo "无法访问"

clean:
	rm -rf output/
