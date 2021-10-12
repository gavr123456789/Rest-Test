import strutils, algorithm


var sas = "تقرير مقارنة البصمة التلقائية"
var sus = "التلقائية البصمة مقارنة تقرير"

var x = sas.split(" ").reversed().join(" ")
echo x
echo sus