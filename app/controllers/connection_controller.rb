require 'CSV'

class ConnectionController < ApplicationController

  $MAX_DEGREE = 5

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
    # find connection between two users
    result = ''
    path = ''
    degree = 0
    a = params[:user_a].to_i
    b = params[:user_b].to_i
    if a == b
      result = 'same users' 
    else # continue if users are distinct
      allConnections = Connection.order(:userid_a).to_a;
      tree = buildTree(allConnections, a)
      user2NodeInTree = levelOrderTraveral(tree, b)
      if user2NodeInTree.nil?
        result = 'No path found or degree of connection is more than 5'
      else 
        # user2 found in tree (so degree is <= 5)
        # so prepare the path
        pathArray = getPathToRoot(user2NodeInTree)
        userNamesArray = ReplaceIdByName(pathArray)
        result = 'Path found'
        path = ArrayToString(userNamesArray)
        degree = pathArray.size - 1
      end
    end
    render json: { result: result, path: path, degree: degree } 
  end

  def ReplaceIdByName(arr)
    # replaces all the user ids in array with name
    allUsers = User.order(:id)
    userNames = Array.new
    arr.each do |x|
      userNames << GetUserName(x, allUsers)
    end
    return userNames
  end

  def ArrayToString(arr)
    # converts array into a path with arrows
    result = arr.at(0).to_s
    arr.drop(1).each do |x|
      result = result + ' -> ' +  x.to_s
    end 
    return result
  end

  def GetUserName(id, arr) 
    # return name for a given id
    arr.each do |x|
      if x[:id] == id
        return x[:name]
      end
    end
  end

  def buildTree(arr, n)
    # prepares a tree with root as user1 (we are finding connection between user1 <-> user2)
    # this tree is basically to find the connections from one user (root) to all other users
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
        helper(node, arr, 2)
      end
    end
    return root
  end

  def helper(n, arr, level)
    # helper function to add childrens to a node
    arr.each do |child|
      node = nil
      if child.userid_a == n.value && !(n.ancestors.include? child.userid_b)
        node = Tree.new(child.userid_b)
      elsif child.userid_b == n.value && !(n.ancestors.include? child.userid_a)
        node = Tree.new(child.userid_a)
      end
      # if node is created, add it as a child
      if node != nil
        (node.ancestors.concat n.ancestors) << n.value
        n.children << node
        level += 1
        # not constructing a tree beyond 5 levels, since even if a path > 5 exits, we are not gonna give it to the client
        if level <= $MAX_DEGREE 
          helper(node, arr, level)
        end
      end
    end
  end

  def levelOrderTraveral(root, user2_id)
    # find the node of user2_id, we are doing level order to find the shortest path
    return nil if root.nil? || root.nil? # nothing to search if there is no root
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

    return nil # returns nil if node for user2 not found
  end

  def getPathToRoot(node)
    # constructs a path to root from a given node
    result = Array.new
    node.ancestors.each do |parent|
      result << parent
    end
    result << node.value
    return result
  end
end
