# Original Author's work
class Task
  attr_accessor :name, :parent

  def initialize(name)
    @name = name
    @parent = nil
  end

  def get_time_required
    0.0
  end
end

class AddDryIngredientsTask < Task
  def initialize
    super('Add dry ingredients')
  end

  def get_time_required
    1.0
  end
end

class CompositeTask < Task
  def initialize(name)
    super(name)
    @sub_tasks = []
  end

  def add_sub_task(task)
    @sub_tasks << task
    task.parent = self
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
    task.parent = nil
  end

  def get_time_required
    @sub_tasks.inject(0.0) {|time, task| time += tsk.get_time_required}
  end
end

class MakeBatterTask < CompositeTask

  def initialize
    super('Make batter')
    add_sub_task(AddDryIngredientsTask.new)
    add_sub_task(AddLiquidsTask.new)
    add_sub_task(MixTask.new)
  end
end

class MakeCakeTask < CompositeTask
  def initialize
    super('Make cake')
    add_sub_task(MakeBatterTask.new)
    add_sub_task(FillPanTask.new)
    add_sub_task(BakeTask.new)
    add_sub_task(FrostTask.new)
    add_sub_task(LickSpoonTask.new)
  end
end

MakeCakeTask.new

# My refactor
class AddDryIngredientsTask
  attr_accessor :name, :parent

  def initialize(name)
    @name = name
    @parent = nil
  end

  def get_time_required
    1.0
  end

  def run
    # Do Stuff
  end
end

class BakeTask
  attr_accessor :name, :parent

  def initialize(name)
    @name = name
    @parent = nil
  end

  def get_time_required
    10.0
  end

  def run
    # Do Stuff
  end
end

class MakeBatterCompositeTask
  def initialize(sub_tasks)
    @sub_tasks = sub_tasks
  end

  def add_sub_task(task)
    @sub_tasks << task
    task.parent = self
  end

  def compose
    @sub_tasks.each do
      task.parent = self
    end
  end

  def decompose
    @sub_tasks.each do
      task.parent = nil
    end
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
    task.parent = nil
  end

  def run
    @sub_tasks.each do
      task.run
    end
  end

  def get_time_required
    @sub_tasks.inject(0.0) {|time, task| time += task.get_time_required}
  end
end

class MakeCakeCompositeTask
  def initialize(sub_tasks)
    @sub_tasks = sub_tasks
  end

  def add_sub_task(task)
    @sub_tasks << task
    task.parent = self
  end

  def compose
    @sub_tasks.each do
      task.parent = self
    end
  end

  def decompose
    @sub_tasks.each do
      task.parent = nil
    end
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
    task.parent = nil
  end

  def run
    @sub_tasks.each do
      task.run
    end
  end
end

make_cake = MakeCakeCompositeTask.new([
  MakeBatterCompositeTask.new([
    AddDryIngredientsTask.new,
    AddLiquidsTask.new,
    MixTask.new
  ]),
  FillPanTask.new,
  BakeTask.new,
  FrostTask.new,
  LickSpoonTask.new
])

make_cake.compose
make_cake.run
