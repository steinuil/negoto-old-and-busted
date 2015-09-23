/* var n = (window.location.hash !== "") ? (window.location.hash.substring(4)) : -1,
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
}); */

//function cycleImage(string)

// Quote a post number
function quote(id) {
    console.log("Quoting reply n." + id)
    document.getElementById("body").value += (">>" + id + "\n");
}

// Expand images
/* function in_deflate(post, img, exp) {
	folder = exp ? "src" : "thumb"
	document.getElementById(post).getElementsByTagName('img')[0].setAttribute('src', "/" + folder + "/" + img
*/

// AJAX
function send_post() {

	document.getElementById('button').disabled = true;
	document.getElementById('button').value = 'Uploading...';

	var body = document.getElementById('body').value,
		name = document.getElementById('name').value,
		file = document.getElementById('file').files[0],
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
			sage: sage,
			file: file
		},
		success: function() {
			document.getElementById('body').value = '';
			document.getElementById('button').value = 'Sent';
		}
	})

	document.getElementById('button').disabled = false;
};
