package main

import (
	"fmt"
)

func main() {
    for v :=1; v <= 100; v++ {
        // % - оператор модуля, дает остаток после целочисленного деления
        if v % 3 ==0 {
            fmt.Println(v)
        }
    }
}