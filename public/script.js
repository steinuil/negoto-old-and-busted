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


//function cycleImage(string)


// AJAX
function send_post() {
	
	var body = document.getElementById('body').value,
		name = document.getElementById('name').value,
		sage = document.getElementById('sage').value,
		board = document.getElementById('board').value,
		thread = document.getElementById('thread').value;

	if (body === "") {
		alert("Can't post without a post nigga");
		return;
	}
	
	minAjax({
		url: "/post",
		type: "POST",
		data: {
			name: name,
			board: board,
			thread: thread,
			body: body,
			sage: sage
		},
		success: function() {
			document.getElementById('body').value = '';
		}
	})
};
