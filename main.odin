package main

import rl "vendor:raylib"


Status :: enum {
  pending,
  ongoing,
  finished,
  interrupted
}

Colonist :: struct {
  // drawing information
  position: rl.Vector2,
  radius: f32,
  color: rl.Color,

  // movement
  velocity: rl.Vector2,
  rotation: f32,
  targetPosition: rl.Vector2,

  // basic colonist information
  name: string,

  // skills
  running: int,
  building: int,
  plants: int,
  shooting: int,
  melee: int,
}

Colony :: struct {
  colonists: [64]Colonist,

  // resources
  wood: int,
  stone: int,
}

World :: struct {
  width: i32,
  height: i32,
}

DecisionCard :: struct {
  text: cstring,
  bounds: rl.Rectangle,
  status: Status,
  onClick: proc(colony: ^Colony, world: World),
  update: proc(colony: ^Colony, world: World, card: ^DecisionCard, delta: f32),
}

main :: proc() {
  colony: Colony
  colony.colonists[0] = Colonist {
    position = rl.Vector2 {100, 100},
    radius = 10,
    color = rl.Color { 120, 0, 255, 255},

    name = "Bob",

    running = 10,
    building = 2,
    plants = 3,
    shooting = 1,
    melee = 8,
  }
  colony.colonists[1] = Colonist {
    position = rl.Vector2 {150, 110},
    radius = 10,
    color = rl.Color { 170, 0, 205, 255},

    name = "Alice",

    running = 5,
    building = 7,
    plants = 7,
    shooting = 8,
    melee = 1,
  }

  cardCount := 0
  cards: [64]DecisionCard
  cards[0] = DecisionCard {
    text = "go to the center",
    bounds = rl.Rectangle { 590, 10, 200, 50 },
    status = Status.pending,
    onClick = GoToCenter_OnClick,
    update = GoToCenter_Update
  }
  cardCount += 1

  world := World {
    height = 450,
    width = 800,
  }
  rl.InitWindow(world.width, world.height, "Raylib")

  rl.SetTargetFPS(165)
  
  delta, last_time: f64

  for !rl.WindowShouldClose() {
    // Update:
    delta = rl.GetTime() - last_time
    last_time = rl.GetTime()

    // Draw:
    rl.BeginDrawing()

    rl.ClearBackground(rl.WHITE)


    rl.DrawText("Ongoing: ", i32(cards[0].bounds.x), world.height/2 - 14, 14, rl.BLACK)
    for &card in cards {
      if (card.status == Status.pending && rl.GuiButton(card.bounds, card.text) == true /* button clicked */) {
        card.status = Status.ongoing
        card.onClick(&colony, world)
      }
      if card.status == Status.ongoing {
        card.update(&colony, world, &card, f32(delta))
        rl.DrawRectangleV(rl.Vector2{card.bounds.x, f32(world.height/2)}, rl.Vector2{card.bounds.width, card.bounds.height}, rl.BLUE)
      }
    }

    for &colonist in colony.colonists {
      if colonist.name != "" {
        colonist.position += colonist.velocity * f32(delta)
        rl.DrawCircleV(colonist.position, 10, colonist.color)
      }
    }

    rl.EndDrawing()
  }

  rl.CloseWindow()
}

DirectionTo :: proc(from: rl.Vector2, to: rl.Vector2) -> rl.Vector2 {
  return rl.Vector2Normalize(to - from)
}
DistanceTo :: proc(from: rl.Vector2, to: rl.Vector2) -> f32 {
  return rl.Vector2Length(to - from);
}

RunnigSkillToMovementSpeed :: proc(running: int) -> f32 {
  return f32((running + 10) * 5)
}

// TODO:
// display ongoing cards
// shortly display finished cards when they just got finished

GoToCenter_OnClick :: proc(colony: ^Colony, world: World) {
  for &colonist in colony.colonists {
    if colonist.name != "" {
      colonist.velocity = DirectionTo(colonist.position, rl.Vector2{f32(world.width/2),f32(world.height/2)}) * RunnigSkillToMovementSpeed(colonist.running)
    }
  }
}
GoToCenter_Update :: proc(colony: ^Colony, world: World, card: ^DecisionCard, delta: f32) {
  allAtCenter := true
  for &colonist in colony.colonists {
    if colonist.name != "" { 
      if DistanceTo(colonist.position, rl.Vector2{f32(world.width/2),f32(world.height/2)}) <= RunnigSkillToMovementSpeed(colonist.running) * delta {
        colonist.velocity = 0
      }
      else {
        allAtCenter = false
      }
    }
  }
  if allAtCenter do card.status = Status.finished
}

