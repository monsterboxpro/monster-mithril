module.exports =
  "$dom":
    get:(sel)->
      document.querySelectorAll(sel)
    addClass:(el,class_name)->
      if (el.classList)
        el.classList.add class_name
      else
        el.className += ' ' + class_name
    removeClass:(el,class_name)->
      if (el.classList)
        el.classList.remove(class_name)
      else
        el.className = el.className.replace(new RegExp('(^|\\b)' + class_name.split(' ').join('|') + '(\\b|$)', 'gi'), ' ')
  "$loc": (n)->
    document.body.setAttribute('location', n)
  "$stop": (e)->
    e.prevDefault()     if e.prevDefault
    e.stopPropagation() if e.stopPropagation
    e.cancelBubble = true
    e.returnValue  = false
