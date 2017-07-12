def System.player_actions
  return unless Input.action
  return unless World.turn == :player

  entity = World.player

  case Input.action
  when :go_west       then move entity, -1,  0
  when :go_east       then move entity, +1,  0
  when :go_north      then move entity,  0, -1
  when :go_south      then move entity,  0, +1
  when :go_north_west then move entity, -1, -1
  when :go_north_east then move entity, +1, -1
  when :go_south_west then move entity, -1, +1
  when :go_south_east then move entity, +1, +1
  when :examine       then examine entity
  when :fire          then fire entity
  when :fire!         then mouse_fire entity
  when :cancel        then cancel entity
  end
end


def move entity, dx, dy
  case entity.player.mode
  when :normal
    move_entity entity, dx, dy
  when :fire, :examine
    move_cursor entity, dx, dy
  end
end


def move_entity entity, dx, dy
  if can_move? entity, dx, dy
    entity.position.x += dx
    entity.position.y += dy

    entity.sprite.dx -= Display.cell_width  * dx
    entity.sprite.dy -= Display.cell_height * dy

    end_turn 1
  end
end


def can_move? entity, dx, dy
  Map.can_walk?(entity.position.x + dx, entity.position.y + dy) &&
  Entities.find_at(entity.position.x + dx, entity.position.y + dy).nil?
end


def move_cursor entity, dx, dy
  entity.player.cx += dx unless entity.player.cx + dx < Camera.x or
                                entity.player.cx + dx > Camera.x + Display.width - 1
  entity.player.cy += dy unless entity.player.cy + dy < Camera.y or
                                entity.player.cy + dy > Camera.y + Display.height - 1
end


def examine entity
  case entity.player.mode
  when :normal
    set_cursor_mode entity, :examine

  when :examine
    entity.player.mode = :normal
  end
end


def fire entity
  case entity.player.mode
  when :normal
    set_cursor_mode entity, :fire

  when :fire
    shoot entity
    entity.player.mode = :normal
  end
end


def mouse_fire entity
  if entity.player.mode == :normal
    entity.player.cx = Input.mouse_x + Camera.x
    entity.player.cy = Input.mouse_y + Camera.y
    shoot entity
  end
end


def shoot entity
  return if entity.player.cx == entity.position.x and
            entity.player.cy == entity.position.y

  lof_opts = {
    x1: entity.position.x,
    y1: entity.position.y,
    x2: entity.player.cx,
    y2: entity.player.cy,
    radius: entity.creature.sight,
    permissive: true,
    ignore_player: true
  }

  line, target = Los.get_line_of_fire_and_target lof_opts

  if target.nil?
    x1 = line.first.x
    y1 = line.first.y
    x2 = line.last.x
    y2 = line.last.y

    puts "No mojo. Create a bullet from #{x1}:#{y1} to #{x2}:#{y2}"
  else
    x1 = line.first.x
    y1 = line.first.y
    x2 = line.last.x
    y2 = line.last.y

    direct = line.first.x == entity.position.x &&
             line.first.y == entity.position.y

    puts "#{direct ? 'Direct hit!' : 'Hit.'} Create a bullet from #{x1}:#{y1} to #{x2}:#{y2}"
  end

  end_turn 1
end


def set_cursor_mode entity, mode
  entity.player.cx   = entity.position.x
  entity.player.cy   = entity.position.y
  entity.player.mode = mode
end


def cancel entity
  entity.player.mode = :normal if entity.player.mode == :fire or
                                  entity.player.mode == :examine
end


def end_turn input_delay
  World.turn = :enemy
  Input.disable_for input_delay
end
