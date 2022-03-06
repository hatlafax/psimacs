##-- AttrAccessorQuery.mako --------------------------------------------------
##
##      A template for the attribute accessor query statement.
##
##-----------------------------------------------------------------------------
<%
    _attrs  = attributes
    _types  = types
    _values = values

    if _attrs is None or len(_attrs) == 0:
        _attrs = []

    ph_type  = '{attribute_type}' if len(_attrs) == 1 else '{type}'
    ph_value = '{expression}...'

    if _types is None or len(_types) == 0:
        _types = [ ph_type ]
    if _values is None or len(_values) == 0:
        _values = _attrs

    num_attr   = len(_attrs)
    num_types  = len(_types)
    num_values = len(_values)

    if num_types > num_attr:
        _types = _types[0:num_attr]
    elif num_attr > num_types:
        _types = _types + [ '-' for _ in range(num_attr - num_types) ]

    if num_values > num_attr:
        _values = _values[0:num_attr]
    elif num_attr > num_values:
        _values = _values + [ '-' for i in range(num_attr - num_values) ]

    def get_type(idx, last_type):
        t = _types[idx]
        if t == '?':
            return ph_type
        elif t == '-':
            return last_type
        return t

    def get_value(idx, last_value):
        v = _values[idx]
        if v == '?':
            return ph_value
        elif v == '-':
            return last_value
        elif v == '.':
            return _attrs[idx]
        return v
    
    new_types = []
    last_type = ph_type
    for i in range(len(_types)):
        last_type = get_type(i, last_type)
        new_types.append(last_type)
    
    new_values = []
    last_value = ph_value
    for i in range(len(_values)):
        last_value = get_value(i, last_value)
        new_values.append(last_value)

    _types  = new_types
    _values = new_values
%>\
##_types  = ${_types}
##_values = ${_values}
%for a, t, v in zip(_attrs, _types, _values):
%if is_init:
    self._${a}: ${t} = ${v}
%else: ## is_init:
%if reader:
@property
def ${a}(self) -> ${t}:
%if document:
    [document_string]
%endif ## document:
    return self._${a}

%endif ## reader:
%if writer:
@${a}.setter
def ${a}(self, value: ${t}) -> None:
%if document:
    [document_string]
%endif ## document:
    self._${a} = value
%endif ## writer:

%endif ## is_init:
%endfor ## for a, t, v in zip(_attrs, _types, _values):
%if is_init:
[attr_accessor_menu]
%endif ## is_init:
