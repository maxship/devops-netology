package main

import "testing"


func testFoots(t *testing.T) {
    var f float32
    f = foots(3.525)
    if f != 11.5649605 {
        t.Error("Правильное значение 11.5649605, а получено ", f)
    }
}