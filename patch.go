// +build ignore

package main

import (
	"bytes"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	pPath := filepath.Join("/var", "tmp", ".env_linux_amd64", "5.13.0", "gcc_64")
	if len(os.Args) >= 2 {
		pPath = os.Args[1]
	}
	if !strings.Contains(pPath, "5.13.0") {
		pPath = filepath.Join(pPath, "5.13.0", "gcc_64")
	}

	for _, fn := range []string{
		"lib/libQt5Core.so.5.13.0",
		"bin/qmake",
	} {
		fn = filepath.Join("./5.13.0/gcc_64/", fn)

		data, err := ioutil.ReadFile(fn)
		if err != nil {
			println("couldn't find", fn)
			continue
		}

		for _, path := range []string{"qt_prfxpath", "qt_epfxpath", "qt_hpfxpath"} {
			path += "="

			start := bytes.Index(data, []byte(path))
			if start == -1 {
				continue
			}

			end := bytes.IndexByte(data[start:], byte(0))
			if end == -1 {
				continue
			}

			rep := append([]byte(path), []byte(pPath)...)
			if lendiff := end - len(rep); lendiff < 0 {
				end -= lendiff
			} else {
				rep = append(rep, bytes.Repeat([]byte{0}, lendiff)...)
			}
			data = bytes.Replace(data, data[start:start+end], rep, -1)
		}

		if err := ioutil.WriteFile(fn, data, 0644); err != nil {
			println("couldn't patch", fn)
		} else {
			println("patched", fn)
		}
	}
}
