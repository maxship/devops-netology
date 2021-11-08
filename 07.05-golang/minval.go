package main

import (
	"fmt"
)

func main() {
    values := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
    minValue := values[0]
    for _, v := range values { // перебор элементов массива
        if (v < minValue) {
            minValue = v
        }
    }

    fmt.Println(minValue)
}