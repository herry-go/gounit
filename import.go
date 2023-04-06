package gounit

import (
	"errors"
	"log"
	"os"
)

// Import 导入sql文件到数据库
func (md *Mysqldump) Import(sqlPath ...string) (err error) {
	if md.isClose == true {
		return errors.New("已调用Close关闭相关资源，无法进行导入")
	}
	pwd, _ := os.Getwd()
	if len(sqlPath) > 0 {
		for _, v := range sqlPath {
			_, err = md.conn.ImportFile(pwd +md.cfg.OutPath + v)
		}
	} else {
		_, err = md.conn.ImportFile(pwd + md.cfg.SQLPath)
	}
	log.Println("导入完成")
	return err
}
