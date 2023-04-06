package gounit

import (
	"errors"
	"fmt"
	"log"
	"path/filepath"
	"runtime"
	"strings"
)

type Gounit struct {
	cfg *UnitConfig
	dm  *Mysqldump
}

var Gunit *Gounit

func GounitStart(config *UnitConfig) error {
	dm, err := New(config.ExportCfg)
	if err != nil {
		log.Println(err)
		return err
	}
	gounit := &Gounit{
		cfg: config,
		dm:  dm,
	}
	if !gounit.EmptyContext() && !gounit.cfg.RebuildContext {
		return err
	}
	err = gounit.BuildContext()
	if err != nil {
		log.Println(err)
		return err
	}
	Gunit = gounit
	return err
}

func (g *Gounit) BuildContext() error {
	path, err := g.dm.Export()
	if err != nil {
		log.Println(err)
		return err
	}
	log.Println(path)
	err = g.dm.Import()
	if err != nil {
		log.Println(err)
		return err
	}
	return err
}

func (g *Gounit) EmptyContext() bool {
	ds, err := g.dm.ShowDatabases()
	if err != nil {
		return false
	}
	var has bool
	for _, v := range ds {
		if v == g.cfg.ExportCfg.DbCfg.DbName + "_test" {
			has = true
			break
		}
	}
	if !has{
		return true
	}
	return false
}

func BeforeEach() {
	pc, file, line, ok := runtime.Caller(1)
	pcName := runtime.FuncForPC(pc).Name()
	log.Println(fmt.Sprintf("%v   %s   %d   %t   %s", pc, file, line, ok, pcName))
	strs := strings.Split(file, "/")
	fileName := strs[len(strs)-1]
	sqlFile := fileName[0:len(fileName)-3] + ".sql"
	log.Println(sqlFile)
	if Gunit == nil {
		err := errors.New("请先开启 Gounit！")
		panic(err)
	}
	err := Gunit.dm.Import(sqlFile)
	if err != nil {
		log.Println(err)
		panic(err)
	}
}
func getPwd() string {
	pc, file, line, ok := runtime.Caller(0)
	pcName := runtime.FuncForPC(pc).Name()
	log.Println(fmt.Sprintf("%v   %s   %d   %t   %s", pc, file, line, ok, pcName))
	dir, _ := filepath.Abs(filepath.Dir(file))
	log.Println(dir)
	return dir
}