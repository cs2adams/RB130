require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative 'todolist'

class TodoListTest < MiniTest::Test

  def setup
    @todo1 = Todo.new("Buy milk")
    @todo2 = Todo.new("Clean room")
    @todo3 = Todo.new("Go to gym")
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end

  def test_to_a
    assert_equal(@todos, @list.to_a)
  end

  def test_size
    assert_equal(3, @list.size)
  end

  def test_first
    assert_equal(@todo1, @list.first)
  end

  def test_last
    assert_equal(@todo3, @list.last)
  end

  def test_shift
    assert_equal(@todo1, @list.shift)
    assert_equal([@todo2, @todo3], @list.to_a)
  end

  def test_pop
    assert_equal(@todo3, @list.pop)
    assert_equal([@todo1, @todo2], @list.to_a)
  end

  def test_done
    refute(@list.done?)
    @todos.each { |todo| todo.done! }
    assert(@list.done?)
  end

  def test_typeerror
    assert_raises(TypeError) { @list.add('String') }
  end

  def test_shovel
    @list << @todo1
    assert_equal(@todos + [@todo1], @list.to_a)
  end

  def test_add
    new_todo = Todo.new("Play a game")
    @todos << new_todo
    @list.add(new_todo)
    assert_equal(@todos, @list.to_a)
  end

  def test_item_at
    assert_raises(IndexError) { @list.item_at(@list.size) }
    @todos.each_with_index do |todo, idx|
      assert_equal(todo, @list.item_at(idx))
    end
  end

  def test_mark_done_at
    assert_raises(IndexError) { @list.mark_done_at(@list.size) }
    
    @todos.each_with_index do |todo, idx|
      refute(todo.done?)
      @list.mark_done_at(idx)
      assert(todo.done?)
    end
  end

  def test_mark_undone_at
    assert_raises(IndexError) { @list.mark_undone_at(@list.size) }
    @todo1.done!
    @list.mark_undone_at(0)
    refute(@todo1.done?)
  end

  def test_done!
    @list.done!
    assert(@todos.all? { |todo| todo.done? })
  end

  def test_remove_at
    assert_raises(IndexError) { @list.remove_at(@list.size) }
    assert_equal(@todo2, @list.remove_at(1))
    assert_equal([@todo1, @todo3], @list.to_a)
  end

  def test_to_s
    output = <<~OUTPUT.chomp
    ---- Today's Todos ----
    [ ] Buy milk
    [ ] Clean room
    [ ] Go to gym
    OUTPUT
  
    assert_equal(output, @list.to_s)
  end

  def test_to_s_2
    @todo2.done!
    output = <<~OUTPUT.chomp
    ---- Today's Todos ----
    [ ] Buy milk
    [X] Clean room
    [ ] Go to gym
    OUTPUT

    assert_equal(output, @list.to_s)
  end

  def test_to_s_3
    @todos.each { |todo| todo.done! }
    output = <<~OUTPUT.chomp
    ---- Today's Todos ----
    [X] Buy milk
    [X] Clean room
    [X] Go to gym
    OUTPUT

    assert_equal(output, @list.to_s)
  end

  def test_each
    @list.each do |todo|
      assert_equal(@todos.shift, todo)
    end
  end

  def test_each_return_value
    assert_equal(@list, @list.each { 'test' } )
  end

  def test_select
    todolist_test = TodoList.new("Selected Todos")
    todolist_test.add(@todo2)

    selection = @list.select do |todo|
      todo.title == 'Clean room'
    end
    assert_equal(todolist_test.to_a, selection.to_a)
  end

  def test_find_by_title
    assert_equal(@todo2, @list.find_by_title("Clean room"))
    assert_nil(@list.find_by_title("Some title"))
  end

  def test_all_done
    @todo1.done!
    @todo3.done!

    todolist_test = TodoList.new("Selected Todos")
    [@todo1, @todo3].each { |todo| todolist_test.add(todo) }

    assert_equal(todolist_test.to_a, @list.all_done.to_a)
  end

  def test_all_not_done
    @todo1.done!
    @todo3.done!

    todolist_test = TodoList.new("Selected Todos")
    todolist_test.add(@todo2)

    assert_equal(todolist_test.to_a, @list.all_not_done.to_a)
  end
  
    
  def test_mark_done
    assert_nil(@list.mark_done("Some title"))
    @list.mark_done("Go to gym")
    refute(@todo2.done?)
    assert(@todo3.done?)
  end

  def test_mark_all_done
    @list.mark_all_done
    @todos.each { |todo| assert(todo.done?) }
  end

  def test_mark_all_undone
    @list.mark_all_done
    @list.mark_all_undone
    @todos.each { |todo| refute(todo.done?) }
  end
end