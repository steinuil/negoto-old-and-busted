function attachment_name() {
  var _ = document.getElementById('filei').value;
  if (_ !== '') {
    var n = _.split("\\");
    document.getElementById('file').textContent = n[n.length-1];
  }
}

var input = {
  ignore: function(e) {
    e.stopPropagation();
    e.preventDefault();
  },

  drop: function(e) {
    e.stopPropagation();
    e.preventDefault();
    document.getElementById("filei").files = e.dataTransfer.files;
  }
}

window.addEventListener('load', function() {
  var dragbox = document.getElementById("file");
  dragbox.addEventListener('drop', input.drop);
  dragbox.addEventListener('dragenter', input.ignore);
  dragbox.addEventListener('dragover', input.ignore);
})
