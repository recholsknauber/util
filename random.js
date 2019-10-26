/*
 Random goings in Javascript.
*/

function sum(x, y) {
    return x + y;
}

let sum_of_plus_one=0;
for (var i = 0, l = 1; l < 100; i++) {
    sum_of_plus_one += sum(i,l);
    l++;
}


// console.log(sum(3,5));
