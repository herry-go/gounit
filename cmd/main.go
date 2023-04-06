package main

import (
	"github.com/herry-go/gounit"
	"log"
)

func main() {
	// 系统日志显示文件和行号
	log.SetFlags(log.Lshortfile | log.LstdFlags)

	cfg := &gounit.UnitConfig{
		ExportCfg: &gounit.ExportConfig{
			Debug:        true,
			IsExportData: false,
			IsCreateDB:   true,
			OutZip:       false,
			OutPath:      "/testdata/base",
			SQLPath:      "/testdata/base/udcp_policy.sql",
			DbCfg: &gounit.DbConfig{
				Address: "10.20.22.113",
				Port:    10002,
				User:    "root",
				Passwd:  "Udcp2022cs",
				DbName:  "udcp_policy",
			},
		},
		RebuildContext: false,
	}
	err := gounit.GounitStart(cfg)
	if err != nil {
		log.Println(err)
		return
	}

	gounit.BeforeEach()


	//dm, err := gounit.New(cfg)
	//if err != nil {
	//	log.Println(err)
	//	return
	//}
	//// 导出
	//path, err := dm.Export()
	//log.Println(err)
	//log.Println(path)
	//
	//// 导入
	//err = dm.Import()
	//if err != nil {
	//	log.Println(err)
	//	return
	//}

	select {}
}
