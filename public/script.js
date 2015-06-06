function quote(id) {
    console.log("Quoting reply n." + id)
    document.getElementById("body").value += (">>" + id + "\n");
}

var n = (window.location.hash !== "") ? (window.location.hash.substring(4)) : -1,
    post = document.getElementsByClassName("post");

// Keyboard controls
document.addEventListener("keydown", function(event) {
	event = event || window.event;
	var target = event.target || event.srcElement;
	var targetTagName = (target.nodeType == 1) ? target.nodeName.toUpperCase() : "";
	if (!/INPUT|SELECT|TEXTAREA/.test(targetTagName)) {
		var post_n = post.length -1;
		switch (event.keyCode) {
			case 74:
				(n === post_n) ? n = 0 : n += 1;
				document.location = ("#" + post[n].getAttribute('id'));
				break;
			case 75:
				(n === 0) ? n = post_n : n -= 1;
				document.location = ("#" + post[n].getAttribute('id'));
				break;
			case 82:
				quote(post[n].getAttribute('id'));
				break;
			case 68:
				n = -1;
				document.location = "#"
				break;
		};
	};
});

/*
var xhr = new XMLHttpRequest(),
    xhr2 = new XMLHttpRequest(),
	test = encodeURIComponent("a");

xhr.open('GET', "/ss.txt", true);
xhr.send();
xhr.onload = function() { console.log(xhr.responseText); }

xhr2.open('POST', "/test", true);
xhr2.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
xhr2.send("test=" + test);
xhr2.onload = function() { console.log(xhr2.responseText + "\n" + xhr2.status) };
*/
