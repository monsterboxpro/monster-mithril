$layout = (ctrl, content, opts={}) =>
  kind = opts.layout || 'application'
  data =
    content: content
    ctrl: ctrl
  app.layouts[kind].view data
module.exports = $layout
