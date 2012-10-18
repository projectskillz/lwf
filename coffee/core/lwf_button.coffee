#
# Copyright (C) 2012 GREE, Inc.
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#

Condition = Format.ButtonCondition.Condition

class Button extends IObject
  constructor:(lwf, parent, objId, instId) ->
    super(lwf, parent, Format.LObject.Type.BUTTON, objId, instId)
    @invert = new Matrix()
    @hitX = Number.MIN_VALUE
    @hitY = Number.MIN_VALUE
    if objId >= 0
      @data = lwf.data.buttons[objId]
      @dataMatrixId = @data.matrixId
      @width = @data.width
      @height = @data.height
    else
      @width = 0
      @height = 0

    @handler = lwf.getButtonEventHandlers(@)
    @handler.load(@) if @handler?.load?

  exec:(matrixId = 0, colorTransformId = 0) ->
    super(matrixId, colorTransformId)
    @handler.enterFrame(@) if @handler?.enterFrame?
    return

  update:(m, c) ->
    super(m, c)
    @handler.update(@) if @handler?.update?
    return

  render:(v, rOffset) ->
    @handler.render(@) if v and @handler?.render?
    return

  destroy: ->
    @lwf.clearFocus(this)
    @handler.unload(@) if @handler?.unload?
    super
    return

  linkButton: ->
    @buttonLink = @lwf.buttonHead
    @lwf.buttonHead = @
    return

  checkHit:(px, py) ->
    Utility.invertMatrix(@invert, @matrix)
    [x, y] = Utility.calcMatrixToPoint(px, py, @invert)
    if x >= 0 and x < @data.width and y >= 0 and y < @data.height
      @hitX = x
      @hitY = y
      return true
    else
      @hitX = Number.MIN_VALUE
      @hitY = Number.MIN_VALUE
      return false

  rollOver: ->
    if @handler?.rollOver?
      return unless @handler.rollOver(@)
    @playAnimation(Condition.ROLLOVER)
    return

  rollOut: ->
    if @handler?.rollOut?
      return unless @handler.rollOut(@)
    @playAnimation(Condition.ROLLOUT)
    return

  press: ->
    if @handler?.press?
      return unless @handler.press(@)
    @playAnimation(Condition.PRESS)
    return

  release: ->
    if @handler?.release?
      return unless @handler.release(@)
    @playAnimation(Condition.RELEASE)
    return

  keyPress: ->
    if @handler?.keyPress?
      return unless @handler.keyPress(@)
    @playAnimation(Condition.KEYPRESS, code)
    return

  playAnimation:(condition, code = 0) ->
    conditions = @lwf.data.buttonConditions
    for i in [0...@data.conditions]
      c = conditions[@data.conditionId + i]
      if (c.condition & condition) isnt 0 and
          (condition isnt Condition.KEYPRESS or c.keyCode is code)
        @lwf.playAnimation(c.animationId, @parent, @)
    return
