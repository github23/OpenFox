function f() {
  var k = 0;
  
  var g = function() {
    return ++k;
  }

  return g;
}

function h() {
  for (var i = 0; i < 10; ++i) {
    var vf = f();
    assertEq(vf(), 1);
    assertEq(vf(), 2);
  }
}

h();

checkStats({
    recorderAborted: 0,
});

