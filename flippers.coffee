
after = (ms, fn)-> tid = setTimeout fn, ms; stop: -> clearTimeout tid
every = (ms, fn)-> iid = setInterval fn, ms; stop: -> clearInterval iid

do ($ = jQuery)->
	
	$Flipper = (part)->
		$new_flipper = $("<span class='flipper'>").text(part)
		$new_flipper.addClass "numerical" if part.match /^\d/
		$new_flipper
	
	$.fn.flippers = (text, splitter=" ")->
		
		parts = text.split splitter
		
		@each ->
			$container = $(@)
			
			# Match new parts with old flippers 
			$old_flippers = $container.children().not(".removed")
			$matched_flippers = $()
			matched_$flippers = for part in parts
				found_first = no
				$old_flippers.not($matched_flippers).filter (i, flipper)->
					return no if found_first
					matches = $(flipper).text() is part
					if matches
						$matched_flippers = $matched_flippers.add flipper
						found_first = yes
					matches
			
			# Remove non-matching flippers
			$old_flippers.not($matched_flippers).each (i, flipper)->
				after 2000, -> $flipper.remove()
				$flipper = $(flipper)
					.removeClass "added"
					.addClass "removed"
			
			# Add new flippers
			$current_flippers = for part, i in parts
				$old_flipper = matched_$flippers[i]
				$prev_flipper = matched_$flippers[i-1] if i > 0
				$next_flipper = matched_$flippers[i+1]
				
				$current_flipper = $old_flipper
				
				unless $old_flipper?.length
					$current_flipper = $new_flipper = $Flipper(part)
					
					# @TODO: utilize more information when deciding where to place new flippers
					if $next_flipper?.length
						$new_flipper.insertBefore($next_flipper)
					else if $prev_flipper?.length
						$new_flipper.insertAfter($prev_flipper)
					else if i is 0
						$new_flipper.prependTo($container)
					else
						$new_flipper.appendTo($container)
					
					$new_flipper.addClass "added just-added"
					
				$current_flipper
			
			
			# Update the layout
			
			copy_position = ({$from, $to, include_margin})->
				$to.css
					left: $from.offset().left + if include_margin then $from.css("margin-left") else 0
					top: $from.offset().top + if include_margin then $from.css("margin-top") else 0
					width: $from.width()
					height: $from.height()
					position: "absolute"
			
			# @TODO: also relayout removed flippers
			$layout = $(@cloneNode(no))
				.addClass("layout-flippers")
				.insertBefore(@)
			
			if $layout.is ":hidden"
				$layout.show()
			
			$layed_out_flippers = for part, i in parts
				$Flipper(part).appendTo($layout)
			
			for part, i in parts
				$flipper = $current_flippers[i]
				$layed_out_flipper = $layed_out_flippers[i]
				
				console.error $flipper.text(), $layed_out_flipper.text() if $flipper.text() isnt $layed_out_flipper.text()
				# @TODO: allow transitions to occur uninterrupted by checking to see if it needs to move before moving it?
				
				if $flipper.hasClass "just-added"
					copy_position $from: $layed_out_flipper, $to: $flipper, include_margin: yes
					$flipper.removeClass "just-added"
				
				copy_position $from: $layed_out_flipper, $to: $flipper
			
			$layout.remove()
