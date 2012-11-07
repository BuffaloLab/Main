import weakref, new, inspect

class WeakCallableProxy(object):
  '''
  Our own proxy object which enables weak references to bound and unbound
  methods and arbitrary callables. Pulls information about the function,
  class, and instance out of a bound method. Stores a weak reference to the
  instance to support garbage collection.

  @organization: IBM Corporation
  @copyright: Copyright (c) 2005, 2006 IBM Corporation
  @license: The BSD License
  '''
  def __init__(self, cb):
    self.klass = None
    self.inst = None
    self.func = None

    # Unbound function or static class method.
    if inspect.isfunction(cb) or inspect.isclass(cb.im_self):
      self.func = cb
    # Bound class method.
    else:
      self.klass = cb.im_class
      self.inst = weakref.ref(cb.im_self)
      self.func = cb.im_func

  def __call__(self, *args, **kwargs):
    '''
    Proxy for a call to the weak referenced object. Take arbitrary params to
    pass to the callable.

    @raise ReferenceError: When the weak reference refers to a dead object
    '''
    if self.inst is not None and self.inst() is None:
      raise ReferenceError
    elif self.inst is not None:
      # build a new instance method with a strong reference to the instance
      mtd = new.instancemethod(self.func, self.inst(), self.klass)
    else:
      # not a bound method, just return the func
      mtd = self.func
    # invoke the callable and return the result
    return mtd(*args, **kwargs)

  def __eq__(self, other):
    '''
    Compare the held function and instance with that held by another proxy.

    @param other: Another proxy object
    @type other: L{Proxy}
    @return: Whether this func/inst pair is equal to the one in the other
    proxy object or not
    @rtype: boolean
    '''
    try:
      #return self.func == other.func and self.inst() == other.inst()
      return self.func == other.func and ((self.inst is None and other.inst is None) or self.inst() == other.inst())
    except Exception:
      return False

  def __ne__(self, other):
    '''
    Inverse of __eq__.
    '''
    return not self.__eq__(other)

  def isDead(self):
    '''
    Determines of referenced instance is dead.
    '''
    return self.inst is not None and self.inst() is None

