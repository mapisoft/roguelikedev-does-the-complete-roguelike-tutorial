module Renderer::UI

  def self.before
    Display.clear_ui
    Display.composition true

    @cursor_hidden = false if @cursor_hidden and Input.mouse_moved?
  end


  def self.render
    entity = World.player

    @cursor_hidden = true if Input.disabled?

    draw_line_of_fire entity
    draw_cursor entity

    draw_log

    if Game.debug
      Display.print_log "Player: #{entity.position.x}:#{entity.position.y}", 0, 0
      Display.print_log "Cursor: #{Input.cursor.x}:#{Input.cursor.y}", 0, 1
    end
  end


  internal def self.draw_line_of_fire entity
    return if World.turn != :player

    return if entity.sprite.offset.x != 0 or
              entity.sprite.offset.y != 0

    return if @cursor_hidden and
              entity.player.mode != :fire

    return if entity.player.mode != :normal and
              entity.player.mode != :fire

    target = if entity.player.mode == :fire
             then entity.player.cursor
             else Input.cursor
             end

    return if Fov.at(target) != :full

    line = Los.line_of_fire(
      from: entity.position,
      to: target,
      radius: entity.creature.sight
    ).reject do |point|
      Fov.at(point) != :full ||
      point.x == entity.position.x &&
      point.y == entity.position.y
    end.map do |point|
      point - Camera.position
    end

    char  = '¿'.ord

    color = if entity.player.mode == :fire
            then '#aaaa0000'
            else '#aa00aa00'
            end

    Display.draw_set line, char, color
  end


  internal def self.draw_cursor entity
    target =
    if entity.player.mode == :fire or entity.player.mode == :examine
    then entity.player.cursor - Camera.position
    else Input.mouse
    end

    char  = '¿'.ord
    color = Terminal.color_from_name 'white'

    Display.draw char, color, target
  end


  internal def self.draw_log
    count = 5
    lines = Log.last count
    Display.print_log_lines lines, 0, Display.height - 1, direction: :up
  end


  def self.after
    Display.composition false
  end

end
