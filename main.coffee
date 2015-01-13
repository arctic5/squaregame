# globals
__entities = []
__count = 0
currentKey = null
lastKey = null
keybyte = 0x0
LEFT = 0x1
RIGHT = 0x2
UP = 0x4
DOWN = 0x8

class Entity
    constructor: () ->
        @id = (+new Date()).toString(16) + (Math.random() * 100000000 | 0).toString(16)
        @components = {}
        __entities.push(this)
        __count++
    addComponent: (component) ->
        @components[component.name] = component
    showData: ->
        @str = JSON.stringify(this, null, 4)
        console.log(@str)
        return @str
        
Component = 
    health: (value) ->
        @name = "health"
        @value = value

    physics: (x, y, vspeed = 0, hspeed = 0, friction = 0.7, solid = false) ->
        @name = "physics"
        @x = x
        @y = y
        @vspeed = Math.min(vspeed, 4)
        @hspeed = Math.min(hspeed, 4)
        @friction = friction
        
    sprite: (frames, xorig, yorig, bbox) ->
        @name = "sprite"
        @frames = frames
        @x = xorig
        @y = yorig
        @bbox = bbox [0, frames[0].width, 0, frames[0].height]
    draw: () ->
        @name = "draw"
    controllable: () ->
        @name = "controllable"

Sys = 
    canvas: 
        init: ->
            @canvas = document.getElementById('canvas')
            @ctx = @canvas.getContext('2d')
            [@canvas.width, @canvas.height] = [600, 800]
            @rect = @canvas.getBoundingClientRect();
        clear: () ->
            @ctx.save()
            @ctx.setTransform(1, 0, 0, 1, 0, 0)
            @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
            @ctx.restore()
    
    rendering: (ent)->
        if (@ent.components.draw)
            Sys.canvas.clear()
            Sys.canvas.ctx.beginPath()
            Sys.canvas.ctx.fillRect(@ent.components.physics.x, @ent.components.physics.y,40,40)
    input: 
        init: -> 
            window.addEventListener('keydown', ((event) -> 
                switch (event.keyCode)
                    when 37
                        keybyte |= LEFT
                    when 39
                        keybyte |= RIGHT
                    when 40
                        keybyte |= DOWN
                    when 38
                        keybyte |= UP
            ), true)
            window.addEventListener('keyup', ((event) ->
                switch (event.keyCode)
                    when 37
                        keybyte &= LEFT
                    when 39
                        keybyte &= RIGHT
                    when 40
                        keybyte &= DOWN
                    when 38
                        keybyte &= UP
            ), true)
    
    playercontrol: ->
        if (@ent.components.physics and @ent.components.controllable)
            switch (currentKey)
                when 37
                    keybyte |= LEFT
                when 39
                    keybyte |= RIGHT
                when 40
                    keybyte |= DOWN
                when 38
                    keybyte |= UP
            switch (lastKey)
                when 37
                    keybyte &= LEFT
                when 39
                    keybyte &= RIGHT
                when 40
                    keybyte &= DOWN
                when 38
                    keybyte &= UP
    movement: ->
        if (@ent.components.physics and @ent.components.controllable)
            if (keybyte & LEFT)
                @ent.components.physics.vspeed -= 5
            if (keybyte & RIGHT)
                @ent.components.physics.vspeed += 5
            if (keybyte & UP)
                @ent.components.physics.hspeed -= 5
            if (keybyte & DOWN)
                @ent.components.physics.hspeed += 5
            
            @ent.components.physics.x += Math.min(Math.abs(@ent.components.physics.vspeed), 7) * Math.sign(@ent.components.physics.vspeed)
            @ent.components.physics.y += Math.min(Math.abs(@ent.components.physics.hspeed), 7) * Math.sign(@ent.components.physics.hspeed)
            @ent.components.physics.vspeed *= @ent.components.physics.friction
            @ent.components.physics.hspeed *= @ent.components.physics.friction
    loop: () ->
        for @ent in __entities
            Sys.playercontrol()
            Sys.rendering()
            Sys.movement()
        currentKey = null
        lastKey = null
        keybyte = 0x0
        setTimeout((-> requestAnimationFrame(Sys.loop)), 1000 / 30)
class Player
    constructor: () ->
        @player = new Entity
        @player.addComponent(new Component.health(2))
        @player.addComponent(new Component.physics(0,0))
        @player.addComponent(new Component.controllable())
        @player.addComponent(new Component.draw())
        @player.showData()
        
new Player
Sys.canvas.init()
Sys.input.init()
Sys.loop()