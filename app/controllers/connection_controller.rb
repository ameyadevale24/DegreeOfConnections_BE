require 'CSV'

class ConnectionController < ApplicationController
  def index
    render json: Connection.order(:userid_a).to_a
  end

  def store
    csv = CSV.parse(params[:file].read, :headers=>true) 
    csv.each do |row|
      Connection.create(:userid_a => row['user1id'], :userid_b => row['user2id'])
    end
  end

  def connectionBetween
    a = params[:user_a].to_i
    b = params[:user_b].to_i
    if a == b
      render json: 'Same user'
    end
    # results = Connection.where('userid_a=? OR userid_b=?', a, a).select('userid_a, userid_b')
    path = Array.new
    allConnections = Connection.order(:userid_a).to_a;
    tree = makeTree(allConnections, a)
    user2_node = levelOrderTraveral(tree, b)
    path = getPathToRoot(user2_node)
    #findConnection(a, b, allConnections, 0, -1, path)
    userNames = ReplaceIdByName(path)
    render json: { path: ArrayToString(userNames), degree: path.size - 1 } 
  end

  def findConnection(a, b, arr, degree, parent, path)
    degree += 1
    path << a
    if degree > 5
      return -1
    end
    temp = Array.new
    arr.each do |x|
      if x.userid_a == a && x.userid_b != parent
        temp << x.userid_b
      elsif x.userid_b == a && x.userid_a != parent
        temp << x.userid_a
      end
    end
    p temp
    if temp.length == 0
      return -1
    elsif temp.include? b
      path << b
      return degree
    else
      temp.each do |x|
        ret = findConnection(x, b, arr, degree, a, path)
        if ret != -1
          return ret
        end
      end
    end
  end

  def ReplaceIdByName(arr)
    allUsers = User.order(:id)
    userNames = Array.new
    arr.each do |x|
      userNames << GetUserName(x, allUsers)
    end
    return userNames
  end

  def ArrayToString(arr)
    ret = arr.at(0).to_s
    arr.drop(1).each do |x|
      ret = ret + ' -> ' +  x.to_s
    end 
    return ret
  end

  def GetUserName(id, arr) 
    arr.each do |x|
      if x[:id] == id
        return x[:name]
      end
    end
  end

  def makeTree(arr, n)
    # prepares a tree with root as user1 (we are finding connection between user1 <-> user2)
    root = Tree.new(n)
    root.ancestors << nil
    arr.each do |child|
      node = nil
      if child.userid_a == n
        node = Tree.new(child.userid_b)
      elsif child.userid_b == n
        node = Tree.new(child.userid_a)
      end
      if node != nil
        node.ancestors << n
        root.children << node
        helper(node, arr)
      end
    end
    return root
  end

  def helper(n, arr)
    arr.each do |child|
      node = nil
      if child.userid_a == n.value && !(n.ancestors.include? child.userid_b)
        node = Tree.new(child.userid_b)
      elsif child.userid_b == n.value && !(n.ancestors.include? child.userid_a)
        node = Tree.new(child.userid_a)
      end
      if node != nil
        (node.ancestors.concat n.ancestors) << n.value
        n.children << node
        helper(node, arr)
      end
    end
  end

  def levelOrderTraveral(root, user2_id)
    return nil if root.nil? || root.nil? # nothing to do if there is no node or root to begin the search
    queue = Queue.new
    queue.enq(root)
    while !queue.empty?
      node = queue.deq
      if node.value == user2_id
        return node
      end

      # keep moving the levels in tree by adding children in queue
      node.children.each do |child| queue.enq(child) end
    end

    return nil # returns node found in BST else default value nil
  end

  def getPathToRoot(node)
    result = Array.new
    node.ancestors.each do |parent|
      result << parent
    end
    result << node.value
    return result
  end
end
