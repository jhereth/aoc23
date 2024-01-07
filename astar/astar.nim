import std/heapqueue
import std/tables
import typetraits

type Node = int
type Cost = int
let start: Node = 0
let goal: Node = 4


const nilNode : Node = low(int)  # !! <- can't be used as normal value

type Candidate = object
    priority: int
    node: Node

proc `<`(lhs, rhs: Candidate): bool =
    lhs.priority < rhs.priority

# frontier = PriorityQueue()
var frontier = initHeapQueue[Candidate]()


# frontier.put(start, 0)
frontier.push(Candidate(node: start, priority: 0))
# came_from = dict()
var cameFrom = newTable[Node, Node]()
# came_from[start] = None
cameFrom[start] = nilNode
echo cameFrom.type.name

# cost_so_far = dict()
var costSoFar = newTable[Node, Cost]()
# cost_so_far[start] = 0
costSoFar[start] = 0


iterator neighbours(n: Node) : Node =
    yield n - 1
    yield n + 1

proc cost(start, goal: Node) : Cost =
    goal - start

proc heuristic(start, goal: Node) : Cost =
    goal - start

# while not frontier.empty():
while frontier.len > 0:
#    current = frontier.get()
    let current = frontier.pop.node
    echo "current node is " & $current
#    if current == goal:
#       break
    if current == goal:
        break
#    for next in graph.neighbors(current):
    for next in neighbours(current):
#       new_cost = cost_so_far[current] + graph.cost(current, next)
        let newCost = costSoFar[current] + cost(current, next)
#       if next not in cost_so_far or new_cost < cost_so_far[next]:
        echo costSoFar
        var oldCost : Cost
        try:
            oldCost = costSoFar[next]
        except:
            oldCost = high(Cost)
        if newCost < oldCost:
#          cost_so_far[next] = new_cost
            costSoFar[next] = newCost
#          priority = new_cost + heuristic(goal, next)
            let priority = newCost + heuristic(next, goal)
#          frontier.put(next, priority)
            frontier.push(Candidate(node: next, priority: priority))
#          came_from[next] = current
            cameFrom[next] = current


proc reconstructPath(start, goal: Node, cameFrom: TableRef[Node, Node])  = 
    var current = goal
    echo current
    while current != start:
        current = cameFrom[current]
        echo current
echo start
echo goal
echo cameFrom
echo costSoFar

reconstructPath(start, goal, cameFrom)
