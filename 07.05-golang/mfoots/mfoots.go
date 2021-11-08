package main

import "fmt"


func foots (m float32) float32 {
    output := m / 0.3048
    return output

}

func main() {
    fmt.Println(foots(3.525), "футов")
}