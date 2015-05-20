function quote(id) {
    console.log("Quoting reply n." + id)
    document.getElementById("body").value += (">>" + id + "\n")
}
