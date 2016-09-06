class MagLove {
  
  constructor(template, host="127.0.0.1", port="3000", endpoint="maglove") {
    this.template = template
    this.templates = []
    this.host = host
    this.port = port
    this.endpoint = endpoint
    this.socket = null

    // Connect to WebSocket
    this.socket = new WebSocket(`ws://${this.host}:${this.port}/${this.endpoint}`)
    this.socket.onopen = this.onSocketOpen.bind(this)
    this.socket.onmessage = this.onSocketMessage.bind(this)
    this.socket.onclose = this.onSocketClose.bind(this)
  }
  
  onSocketOpen(event) {
    console.log("MagLove Opened")
    this.send("init")
  }
  
  onSocketMessage(event) {
    const message = JSON.parse(event.data)
    this[message.command](message)
  }
  
  onSocketClose(event) {
    console.log("MagLove Closed")
  }
  
  send(command, data={}) {
    data.command = command
    this.socket.send(JSON.stringify(data))
  }
  
  init(message) {
    console.log("MagLove Initialized")
    this.templates = message.templates
    this.send("watch")
    if(window.ThemeApi) {
      window.ThemeApi.init({deviceId: 'AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE', appId: 'com.magloft.maglove', apiHost: 'www.magloft.com'})
    }
  }
  
  html(message) {
    if(message.template === this.template) {
      document.body.innerHTML = message.contents
    }
    $(window.document).trigger("typeloftWidgetChanged")
  }
  
  css(message) {
    document.getElementById("theme-css").textContent = message.contents
  }
  
  js(message) {
    document.getElementById("theme-js").remove()
    let script = document.createElement('script')
    script.id = "theme-js"
    script.textContent = message.contents
    document.getElementsByTagName('head')[0].appendChild(script)
    
    if(window.ThemeApi) {
      window.ThemeApi.init({deviceId: 'AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE', appId: 'com.magloft.maglove', apiHost: 'www.magloft.com'})
    }
  }
}
