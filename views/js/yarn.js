// Helper function akin to that neat jQuery thing
function ß(el) {
  var type = el[0];
  el = el.substring(1);
  switch (type) {
    case '#': return document.getElementById(el);
    case '.': return document.getElementsByClassName(el);
    case '_': return document.getElementsByTagName(el);
  }
}

// Change attachment label name to attachment name
function attachment_name() {
  var _ = ß('#filei').value;
  if (_ !== '') {
    var n = _.split("\\");
    ß('#file').textContent = n[n.length - 1];
  }
}

// Post preview on hover
var preview = {
  show: function(post) {
    var _ = ß('#p' + post.textContent.substring(2));
    if (!_) return;
    var clone = _.cloneNode(true),
        rect = post.getBoundingClientRect();
    clone.className += ' preview';
    clone.style.bottom = window.innerHeight - rect.bottom;
    clone.style.left = rect.right + 5;
    document.body.appendChild(clone);
  },

  destroy: function() {
    var els = ß('.preview');
    while (0 < els.length) els[0].remove();
  }
};

// QR Box
var qr = {
  spawn: function() {
    if (ß('#floating-form')) return;
    var _ = document.createElement('div');
    _.innerHTML = ß('_noscript')[0].textContent;
    var form = _.children[0];
    form.id = 'floating-form';
    form.className = 'draggable';
    document.body.appendChild(form);
    ß('#body').select();
  },

  upload: function() {
    var request = new XMLHttpRequest();
        form = new FormData(document.forms[0]);
    form.append('xhr', true);

    request.upload.onprogress = function(e) {
      if (e.lengthComputable) {
        ß('#send').value = (e.loaded / e.total * 100) + '%';
      }
    }

    request.addEventListener('error', function() {
      console.log(request.responseText);
      ß('#send').value = 'Err';
    });

    request.addEventListener('load', function() {
      console.log(request.responseText);
      qr.destroy();
      refresh();
    });

    request.open('POST', '/post' + window.location.pathname);
    request.send(form);
  },

  destroy: function() {
    var form = ß('#floating-form');
    if (form) form.remove();
  }
};

function to_int(s) {
  var n = parseInt(s);
  return (isNaN(n) || n == null)  ? 0 : n;
}

// Fetch new posts
function refresh() {
  var last = to_int(ß('#thread').lastElementChild['id'].substring(1)),
      request = new XMLHttpRequest();
  ß('#refresh').textContent += 'ing...';

  request.addEventListener('loadend', function() {
    ß('#refresh').textContent = 'Refresh';
  });

  request.addEventListener('load', function() {
    var _ = document.createElement('div');
    _.innerHTML = request.responseText;
    var posts = _.children;

    console.log('Received ' + posts.length + ' posts');
    while (0 < posts.length) ß('#thread').appendChild(posts[0]);
  });

  request.open('GET', '/refresh' + window.location.pathname + '?last=' + last);
  request.send();
}

function quote(id) {
  if (!ß('#body')) qr.spawn();
  ß('#body').value += ('>>' + id + "\n");
}

// Keyboard shortcuts handler
document.onkeypress = function(e) {
  var _ = e.target.tagName;
  if (_ !== 'TEXTAREA' && _ !== 'INPUT') {
    if (e.key === 'q' || e.charCode === 113)
      qr.spawn();
    else if (e.key === 'r' || e.charCode === 114)
      refresh();
    return false;
  }
};

// Draggable
var mouse = {
  start_x: 0,
  start_y: 0,
  offset_x: 0,
  offset_y: 0,
  element: null,

  down : function(e) {
    if (e.button === 0 && e.target.className === 'draggable') {
      mouse.start_x = window.innerWidth - e.clientX;
      mouse.start_y = window.innerHeight - e.clientY;

      mouse.offset_x = to_int(e.target.style.right);
      mouse.offset_y = to_int(e.target.style.bottom);

      mouse.element = e.target;

      document.onmousemove = function(e) {
        var r = window.innerWidth - e.clientX + mouse.offset_x - mouse.start_x,
            b = window.innerHeight - e.clientY + mouse.offset_y - mouse.start_y;
        mouse.element.style.right = (r >= 0 ? r : 0) + 'px';
        mouse.element.style.bottom = (b >= 0 ? b : 0) + 'px';
        document.body.focus();
      }

      return false;
    }
  },

  up: function(e) {
    if (mouse.element) {
      document.onmousemove = null;
      mouse.element = null;
    }
  }
};

document.onmousedown = mouse.down;
document.onmouseup = mouse.up;
