document.onkeypress = keyboard_controls;
document.onmousedown = mouse_down;
document.onmouseup = mouse_up;
var qr = {};

function keyboard_controls(e) {
  var t = e.target.tagName, f = document.getElementById('thread');

  if (t !== 'TEXTAREA' && t !== 'INPUT' && f !== null) {
    if (e.key === 'q' || e.charCode === 113) {
      qr.spawn();
      return false;
    } else if (e.key === 'r' || e.charCode === 114) {
      refresh();
      return false; }}}

function quote(id) {
  if (!document.getElementById('body')) qr.spawn();
  document.getElementById('body').value += ('>>' + id + "\n"); }

function attachment_name() {
  var name = document.getElementById('filei').value;
  if (name != '') {
    name = name.split("\\");
    document.getElementById('file').textContent = name[name.length - 1]; }}

function preview(post) {
  var target = document.getElementById('p' + post.textContent.substring(2)),
      clone = target.cloneNode(true),
      rect = post.getBoundingClientRect();
  clone.className += ' floating';
  clone.style.bottom = window.innerHeight - rect.bottom;
  clone.style.left = rect.right + 5;
  document.body.appendChild(clone);
}

function unpreview() {
  document.getElementsByClassName('floating')[0].remove();
}

// QR box
qr.spawn = function() {
  if (document.getElementById('floating-form')) return;
  var tmp = document.createElement('div');
  tmp.innerHTML = document.getElementsByTagName('noscript')[0].textContent;
  var form = tmp.children[0];
  form.id = 'floating-form';
  form.className = 'draggable';
  document.body.appendChild(form);
  document.getElementById('body').select(); }

qr.destroy = function() {
  var form = document.getElementById('floating-form');
  if (form) document.body.removeChild(form);
}

// AJAX stuff
function upload_post() {
  var request = new XMLHttpRequest(),
      form = new FormData(document.forms[0]),
      url = window.location.pathname;
  form.append('xhr', true);

  request.upload.onprogress = function(e) {
    if (e.lengthComputable) {
      var complete = e.loaded / e.total * 100;
      document.getElementById('send').value = complete + '%';
    }
  }

  request.onerror = function() {
    console.log(request.responseText);
    document.getElementById('send').value = 'Err';
  }

  request.onload = function() {
    console.log(request.responseText);
    qr.destroy();
    refresh();
  }

  request.open('POST', '/post' + url);
  request.send(form); }

function refresh() {
  var last = parseInt(document.getElementById('thread').lastElementChild['id'].substring(1)),
      request = new XMLHttpRequest(),
      url = window.location.pathname;
  document.getElementById('refresh').textContent += 'ing...';

  request.onerror = function() {
    document.getElementById('refresh').textContent = 'Refresh';
  }

  request.onload = function() {
    document.getElementById('refresh').textContent = 'Refresh';
    var html = document.createElement('div');
    html.innerHTML = request.responseText;
    var posts = html.children;
    console.log('Received ' + posts.length + ' posts');
    while (0 < posts.length) // This makes perfect sense.
      document.getElementById('thread').appendChild(posts[0]); }
  request.open('GET', '/refresh' + url + '?last=' + last);
  request.send(); }

// Dragging shit around
var start_x = 0, start_y = 0, offset_x = 0, offset_y = 0, element;

function mouse_down(e) {
  var target = e.target;

	if (e.button === 0 && target.className === "draggable") {
		start_x = window.innerWidth - e.clientX;
		start_y = window.innerHeight - e.clientY;

		offset_x = to_int(target.style.right);
		offset_y = to_int(target.style.bottom);

		element = target;

		document.onmousemove = function(e) {
			var r = window.innerWidth - e.clientX + offset_x - start_x;
			var b = window.innerHeight - e.clientY + offset_y - start_y;
			element.style.right = (r >= 0 ? r : 0) + "px";
			element.style.bottom = (b >= 0 ? b : 0) + "px";
			document.body.focus(); };

		return false; }}

function mouse_up(e) {
	if (element) {
		document.onmousemove = null;
		element = null; }}

function to_int(v) {
	var n = parseInt(v);
	return n == null || isNaN(n) ? 0 : n; }
