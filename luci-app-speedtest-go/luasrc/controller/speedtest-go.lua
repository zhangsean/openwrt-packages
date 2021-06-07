module("luci.controller.speedtest-go", package.seeall)

function index()
	entry({"admin", "status", "speedtest-go"}, template("speedtest-go/speedtest-go"), _("speedtest-go"), 10).leaf = true
end