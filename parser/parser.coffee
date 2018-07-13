class UI
	buffer = new Map()

	constructor: () ->
		@out = document.getElementById 'output'
		# Drag/drop support.
		document.addEventListener 'dragover', (e) => e.preventDefault(); e.dataTransfer.dropEffect = 'none'
		document.addEventListener 'drop', (e) => e.preventDefault()
		@out.addEventListener 'dragover', (e) =>
			e.stopPropagation(); e.preventDefault(); e.dataTransfer.dropEffect = 'copy'
		@out.addEventListener 'drop', (e) => @importer.bind(@) e
		# Showing ui.
		document.getElementById('ui').style.visibility = 'visible'

	importer: (e) ->
		e.stopPropagation()
		e.preventDefault()
		if feed = e.dataTransfer.files[0]
			reader = new FileReader()
			reader.readAsText feed
			listing					= new Set()
			@out.style.background	= 'transparent'
			reader.onload = (e) =>
				for data from @parse e.target.result
					info = "<span class='ip'>#{data.get 'ip'}</span><span class='port'>:#{data.get 'port'}</span>
							#{data.get 'username'}<span class='delim'>:</span>#{data.get 'password'}"
					http = "http://#{data.get 'username'}:#{data.get 'password'}@#{data.get 'ip'}:#{data.get 'port'}"
					setTimeout ((info, http) =>
						@out.innerHTML = "<div class='info'>⟲ .:Loading entry \##{listing.size}:. ⟳</div>"
						listing.add "<div class='liner'><a href='#{http}' target='_blank'>#{info}</a></div>"
					).bind(@, info, http)
				setTimeout (() =>
					@out.innerHTML = [...listing].join ''
					@out.style.background = '#2f2f2f').bind @

	parse: (text) ->
		for line in text.split /\r?\n/ when cut = line.match(/^(\[92m)?\[\+]The /)?[0]
			buffer = new Map [...buffer].concat line[cut.length..].split(",").map (t) -> t.split ':'
			if buffer.has('username') and buffer.has 'password'
				console.log (t = buffer.get 'username').charCodeAt(t.length-1)
				yield buffer
				buffer.clear()

# == Main code ==
ui = new UI()