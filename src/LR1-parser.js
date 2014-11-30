// Generated by CoffeeScript 1.8.0
(function() {
  var AST, BNFGrammar, BNFParser, GrammarDict, GrammarNode, IR, SyntaxParser, SyntaxTable, log, util,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  if (typeof self === 'undefined') {
    util = require('./util.js');
    IR = require('./IR.js');
    BNFParser = require('./BNF-parser.js');
    BNFGrammar = BNFParser.BNFGrammar;
  } else {
    util = self.util;
    IR = self.IR;
    BNFGrammar = self.BNFGrammar;
  }

  SyntaxTable = function(grammar_content, start_stmt, end_lex) {
    this.start_stmt = start_stmt;
    this.end_lex = end_lex;
    this.raw_bnf_grammar = new BNFGrammar(grammar_content);
    this.raw_bnf_grammar.makePlainBNF();
    this.grammar_dict = new GrammarDict(this.raw_bnf_grammar.bnf_grammar_pairs);
    this.live_grammars = null;
    return this;
  };

  SyntaxTable.prototype.init = function() {
    var closure, _i, _len, _ref;
    this.live_grammars = {};
    _ref = this.start_stmt;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      closure = _ref[_i];
      this.initGrammar2Live(closure, this.end_lex, 0);
    }
    return this.expand(0, null);
  };

  SyntaxTable.prototype.initGrammar2Live = function(closure, end_lex, expand_level) {
    var firsts_closure, reprs, _i, _len, _ref;
    firsts_closure = [];
    _ref = (this.grammar_dict.get(closure))['reprs'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      reprs = _ref[_i];
      if (this.grammar_dict.get(reprs[0])) {
        firsts_closure.push(reprs[0]);
      }
      SyntaxTable.addGrammar2Set(closure, reprs, end_lex, this.live_grammars, expand_level);
    }
    return firsts_closure;
  };

  SyntaxTable.addGrammar2Set = function(closure, repr, end_lex, grammar_set, expand_level) {
    var each_end_lex, first_lex, i, isOneOrMore, _i, _len;
    if (expand_level == null) {
      expand_level = 0;
    }
    repr = repr.slice();
    end_lex = end_lex.slice();
    first_lex = repr.shift();
    isOneOrMore = false;
    if (BNFGrammar.isOneOrMore(first_lex)) {
      first_lex = BNFGrammar.removeSpecialMark(first_lex);
      isOneOrMore = true;
    }
    if (!(first_lex in grammar_set)) {
      grammar_set[first_lex] = [];
    }
    if (isOneOrMore) {
      grammar_set[first_lex].repeat = true;
    }
    for (i = _i = 0, _len = end_lex.length; _i < _len; i = ++_i) {
      each_end_lex = end_lex[i];
      if (BNFGrammar.isOneOrMore(each_end_lex)) {
        end_lex[i] = BNFGrammar.removeSpecialMark(each_end_lex);
      }
    }
    return grammar_set[first_lex].push({
      closure: closure,
      repr: repr,
      end_lex: end_lex,
      expand_level: expand_level
    });
  };

  SyntaxTable.mixGrammars = function(a, b) {
    var i, ret;
    ret = {};
    for (i in a) {
      if (!(i in ret)) {
        ret[i] = [];
      }
      ret[i] = ret[i].concat(a[i]);
    }
    for (i in b) {
      if (!(i in ret)) {
        ret[i] = [];
      }
      ret[i] = ret[i].concat(b[i]);
    }
    log(a, 'mix from a');
    log(b, 'mix from b');
    log(ret, 'mixed');
    return ret;
  };

  SyntaxTable.cloneGrammar = function(a) {
    var closure, item, ret, unit, _i, _len, _ref;
    ret = {};
    for (closure in a) {
      ret[closure] = [];
      if (a[closure].repeat) {
        ret[closure].repeat = true;
      }
      _ref = a[closure];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        unit = _ref[_i];
        item = {
          closure: unit['closure'],
          repr: unit['repr'],
          end_lex: unit['end_lex'],
          expand_level: unit['expand_level']
        };
        ret[closure].push(item);
      }
    }
    return ret;
  };

  SyntaxTable.prototype.moveDot = function(dot_lex, next_lex, expand_level) {
    var dot_grammars, each_grammar, grammar, new_live_grammars, ristrict, _i, _len;
    dot_grammars = this.live_grammars[dot_lex];
    log(dot_lex, 'dot-lex -' + dot_lex);
    if (!dot_grammars) {
      this.live_grammars = {};
      return false;
    }
    new_live_grammars = {};
    ristrict = null;
    if (dot_grammars.repeat) {
      log('repeat!');
      new_live_grammars = SyntaxTable.cloneGrammar(this.live_grammars);
      ristrict = [dot_lex];
    }
    dot_grammars.sort(function(a, b) {
      return b['expand_level'] - a['expand_level'];
    });
    for (_i = 0, _len = dot_grammars.length; _i < _len; _i++) {
      each_grammar = dot_grammars[_i];
      if (!each_grammar['repr'].length) {
        if (__indexOf.call(each_grammar['end_lex'], next_lex) >= 0) {
          return {
            expand_level: each_grammar['expand_level'],
            closure: each_grammar['closure']
          };
        }
      } else {
        ristrict && ristrict.push(BNFGrammar.removeSpecialMark(each_grammar['repr'][0]));
        SyntaxTable.addGrammar2Set(each_grammar['closure'], each_grammar['repr'], each_grammar['end_lex'], new_live_grammars, each_grammar['expand_level']);
      }
    }
    this.live_grammars = new_live_grammars;
    if (dot_grammars.repeat) {
      for (grammar in this.live_grammars) {
        if (__indexOf.call(ristrict, grammar) < 0) {
          delete this.live_grammars[grammar];
        }
      }
    }
    this.expand(expand_level, ristrict);
    return false;
  };

  SyntaxTable.prototype.expand = function(expand_level, ristrict) {
    var closure, closure_id, end_lex, expanded_closures, first_lex, firsts_closure, last_ec_len, x, _i, _len, _ref;
    expanded_closures = [];
    last_ec_len = 0;
    if (ristrict) {
      log(ristrict, 'ristrict');
    }
    while (1) {
      for (closure in this.live_grammars) {
        if (ristrict && __indexOf.call(ristrict, closure) < 0) {
          continue;
        }
        if (this.grammar_dict.get(closure)) {
          end_lex = [];
          _ref = this.live_grammars[closure];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            if (x['repr'].length) {
              first_lex = x['repr'][0];
              first_lex = BNFGrammar.isOneOrMore(first_lex) ? BNFGrammar.removeSpecialMark(first_lex) : first_lex;
              util.uniqueConcat(end_lex, this.grammar_dict.findFirst(first_lex));
            } else {
              util.uniqueConcat(end_lex, this.end_lex);
              util.uniqueConcat(end_lex, x['end_lex']);
            }
            if (this.live_grammars[closure].repeat) {
              util.uniqueConcat(end_lex, this.grammar_dict.findFirst(closure));
            }
            closure_id = closure + end_lex.join('');
            if (__indexOf.call(expanded_closures, closure_id) >= 0) {
              end_lex = [];
            }
          }
          if (!end_lex.length) {
            continue;
          }
          expanded_closures.push(closure_id);
          firsts_closure = this.initGrammar2Live(closure, end_lex, expand_level);
          if (ristrict) {
            log(firsts_closure, 'firsts_closure');
            util.uniqueConcat(ristrict, firsts_closure);
          }
        }
      }
      if (last_ec_len === expanded_closures.length) {
        break;
      }
      last_ec_len = expanded_closures.length;
    }
    return null;
  };

  GrammarDict = function(bnf_grammar_pairs) {
    var closure, line, repr, reprs, _i, _j, _len, _len1;
    this.bnf_grammar_pairs = bnf_grammar_pairs;
    this.dict_map = {};
    for (_i = 0, _len = bnf_grammar_pairs.length; _i < _len; _i++) {
      line = bnf_grammar_pairs[_i];
      closure = line[0];
      reprs = line[1] instanceof Array ? line[1] : [line[1]];
      if (!(closure in this.dict_map)) {
        this.dict_map[closure] = GrammarDict.initClosure();
      }
      for (_j = 0, _len1 = reprs.length; _j < _len1; _j++) {
        repr = reprs[_j];
        this.dict_map[closure]['reprs'].push(repr.split(/\s+/));
      }
    }
    this.makeFirstSets();
    return this;
  };

  GrammarDict.initClosure = function() {
    return {
      reprs: [],
      first: [],
      follows: []
    };
  };

  GrammarDict.prototype.get = function(closure) {
    if (BNFGrammar.isOneOrMore(closure)) {
      closure = BNFGrammar.removeSpecialMark(closure);
    }
    return this.dict_map[closure];
  };

  GrammarDict.prototype.makeFirstSets = function() {
    var closure, closure_key, first_set, getFirst, _results;
    getFirst = function(closure_key, first_set, pushed_closures) {
      var closure, repr, _i, _len, _ref, _ref1, _results;
      closure = this.dict_map[closure_key];
      pushed_closures.push(closure_key);
      _ref = closure['reprs'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        repr = _ref[_i];
        if (_ref1 = repr[0], __indexOf.call(pushed_closures, _ref1) >= 0) {
          continue;
        }
        if (repr[0] in this.dict_map) {
          _results.push(getFirst.call(this, repr[0], first_set, pushed_closures));
        } else {
          _results.push(util.uniquePush(first_set, repr[0]));
        }
      }
      return _results;
    };
    _results = [];
    for (closure_key in this.dict_map) {
      closure = this.dict_map[closure_key];
      first_set = closure['first'];
      _results.push(getFirst.call(this, closure_key, first_set, []));
    }
    return _results;
  };

  GrammarDict.prototype.findFirst = function(closures) {
    var closure, ret, _i, _len;
    if (!(closures instanceof Array)) {
      closures = [closures];
    }
    ret = [];
    for (_i = 0, _len = closures.length; _i < _len; _i++) {
      closure = closures[_i];
      if (!(closure in this.dict_map)) {
        util.uniquePush(ret, closure);
      } else {
        util.uniqueConcat(ret, this.dict_map[closure]['first']);
      }
    }
    return ret;
  };

  GrammarNode = function(lex, parent, leaves) {
    if (parent == null) {
      parent = null;
    }
    if (leaves == null) {
      leaves = [];
    }
    this.parent = null;
    this.leaves = leaves;
    this.lex = lex;
    this.value = null;
    if (parent) {
      this.linkParent(parent);
    }
    return this;
  };

  GrammarNode.prototype.isName = function(lex) {
    return lex === this.lex;
  };

  GrammarNode.prototype.getValue = function() {
    return this.value;
  };

  GrammarNode.prototype.setValue = function(val) {
    return this.value = val;
  };

  GrammarNode.prototype.appendLeaf = function(leaf) {
    if (!this.hasLeaf(leaf)) {
      return this.leaves.push(leaf);
    }
  };

  GrammarNode.prototype.prependLeaf = function(leaf) {
    if (!this.hasLeaf(leaf)) {
      return this.leaves.unshift(leaf);
    }
  };

  GrammarNode.prototype.hasLeaf = function(leaf) {
    return __indexOf.call(this.leaves, leaf) >= 0;
  };

  GrammarNode.prototype.findLeaf = function(lex_name) {
    var leaf, _i, _len, _ref;
    _ref = this.leaves;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      leaf = _ref[_i];
      if (leaf.lex === lex_name) {
        return leaf;
      }
    }
    return null;
  };

  GrammarNode.prototype.linkParent = function(parent, use_prepend) {
    if (use_prepend == null) {
      use_prepend = null;
    }
    this.parent = parent;
    if (use_prepend) {
      return parent.prependLeaf(this);
    } else {
      return parent.appendLeaf(this);
    }
  };

  AST = function(syntax_tree, patterns) {
    if (patterns == null) {
      patterns = [];
    }
    this.syntax_tree = syntax_tree;
    this.patterns = patterns;
    AST.cutLeaves(this.syntax_tree, this.patterns);
    return this;
  };

  AST.cutLeaves = function(syntax_tree, patterns) {
    var walk;
    walk = function(node) {
      var leaf, neighbor, new_parent_leaves, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
      _ref = node.leaves;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        leaf = _ref[_i];
        walk(leaf);
      }
      if ((_ref1 = node.lex, __indexOf.call(patterns, _ref1) >= 0) || (node.lex.slice(0, 2) === 'E!' && node.value === null)) {
        new_parent_leaves = [];
        _ref2 = node.parent.leaves;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          neighbor = _ref2[_j];
          if (neighbor === node) {
            new_parent_leaves = new_parent_leaves.concat(node.leaves);
            _ref3 = node.leaves;
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              leaf = _ref3[_k];
              leaf.parent = node.parent;
            }
          } else {
            new_parent_leaves = new_parent_leaves.concat(neighbor);
          }
        }
        node.parent.leaves = new_parent_leaves;
      }
      if (!node.leaves.length) {
        delete node.leaves;
      }
      if (node.value === null) {
        return delete node.value;
      }
    };
    return walk(syntax_tree);
  };

  SyntaxParser = function(input_lex) {
    this.raw_input_lex = input_lex;
    this.input_lex = input_lex.map(function(x) {
      if (x instanceof Array) {
        return x[0];
      } else {
        return x;
      }
    });
    this.input_val = input_lex.map(function(x) {
      if (x instanceof Array) {
        return x[1];
      } else {
        return null;
      }
    });
    this.stack = [];
    this.sync_lex = [];
    this._reduce_cache = {};
    this._reduce_cache_len = {};
    this.tree = new GrammarNode('Syntax');
    return this;
  };

  SyntaxParser.flow = function(args) {
    var ast, ast_cutter, end_lex, grammar, lex_list, mix_map, start_stmt, sync_lex, syntax_parser, syntax_table;
    console.log('SyntaxParser');
    grammar = args.grammar;
    start_stmt = args.start_stmt;
    end_lex = args.end_lex;
    sync_lex = args.sync_lex || [];
    lex_list = args.lex_list;
    mix_map = args.mix_map;
    ast_cutter = args.ast_cutter;
    SyntaxParser.Mix.mixer = function() {
      return mix_map.arrange.apply(mix_map, arguments);
    };
    syntax_table = new SyntaxTable(grammar, start_stmt, end_lex);
    syntax_parser = new SyntaxParser(lex_list);
    syntax_parser.sync_lex = sync_lex;
    syntax_parser.parseTable(syntax_table);
    ast = syntax_parser.getAST(ast_cutter);
    args.ast = ast.syntax_tree;
    return SyntaxParser.Mix.mixer = null;
  };

  SyntaxParser.prototype.getAST = function(patterns) {
    return new AST(this.tree, patterns);
  };

  SyntaxParser.prototype.shift = function() {
    if (this.input_lex.length) {
      return this.stack.push(this.input_lex.shift());
    } else {
      return false;
    }
  };

  SyntaxParser.checkIfReduce = function(syntax_table, stack, lookahead) {
    var cached_index, index, len, result, ret, spcr, _i, _ref, _ref1;
    spcr = SyntaxParser.checkIfReduce;
    cached_index = spcr.getCachedIndex(stack);
    if (cached_index > -1) {
      syntax_table.live_grammars = spcr.checkedLiveGrammars[cached_index];
    }
    if (!syntax_table.live_grammars) {
      syntax_table.init();
    }
    len = stack.length;
    stack.push(lookahead);
    ret = [];
    for (index = _i = _ref = cached_index + 1, _ref1 = len - 1; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; index = _ref <= _ref1 ? ++_i : --_i) {
      log(syntax_table.live_grammars, 'before live grammar');
      result = syntax_table.moveDot(stack[index], stack[index + 1], index + 1);
      log(result, 'after move dot');
      log(syntax_table.live_grammars, 'live grammar');
      log(index + 1, 'move dot index');
      if (result) {
        ret = stack.slice(0, result['expand_level']);
        ret.push(result['closure']);
      }
    }
    stack.pop();
    if (ret.length) {
      spcr.lastCheckedStack = ret.slice(0, -1);
    } else {
      spcr.lastCheckedStack = stack.slice();
    }
    spcr.checkedLiveGrammars = spcr.checkedLiveGrammars.slice(0, spcr.lastCheckedStack.length);
    while (spcr.checkedLiveGrammars.length < spcr.lastCheckedStack.length) {
      spcr.checkedLiveGrammars.push('');
    }
    if (!ret.length) {
      spcr.checkedLiveGrammars[spcr.checkedLiveGrammars.length - 1] = syntax_table.live_grammars;
    }
    if (ret.length) {
      return ret;
    } else {
      return stack;
    }
  };

  SyntaxParser.checkIfReduce.lastCheckedStack = [];

  SyntaxParser.checkIfReduce.checkedLiveGrammars = [];

  SyntaxParser.checkIfReduce.getCachedIndex = function(stack) {
    var index, item, scif, _i, _len;
    scif = SyntaxParser.checkIfReduce;
    for (index = _i = 0, _len = stack.length; _i < _len; index = ++_i) {
      item = stack[index];
      if (scif.lastCheckedStack[index] !== item) {
        index--;
        break;
      }
    }
    if (index === stack.length) {
      return index - 1;
    } else {
      return index;
    }
  };

  SyntaxParser.prototype.mutilReverseReduce = function(syntax_table) {
    var i, result, _i, _ref, _results;
    _results = [];
    for (i = _i = 1, _ref = this.stack.length; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      syntax_table.init();
      result = SyntaxParser.checkIfReduce(syntax_table, this.stack.slice(-i), this.input_lex[0]);
      if (result) {
        this.stack = this.stack.slice(0, this.stack.length - i);
        this.stack.push(result);
        if (i > 1) {
          this.reduce(syntax_table);
          break;
        } else {
          _results.push(void 0);
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  SyntaxParser.prototype.MutilReduce = function(syntax_table) {
    var i, result, _i, _ref, _results;
    _results = [];
    for (i = _i = 0, _ref = this.stack.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      syntax_table.init();
      result = SyntaxParser.checkIfReduce(syntax_table, this.stack.slice(i, this.stack.length), this.input_lex[0]);
      if (result) {
        this.stack = this.stack.slice(0, i);
        this.stack.push(result);
        this.reduce(syntax_table);
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  SyntaxParser.prototype.reduce = function(syntax_table, value_assign) {
    var last_stmt_index, result, stack_changed, sync_index, sync_len;
    if (value_assign == null) {
      value_assign = true;
    }
    log(this.stack, 'before reduce');
    this.generateTree(value_assign);
    syntax_table.live_grammars = null;
    result = SyntaxParser.checkIfReduce(syntax_table, this.stack, this.input_lex[0]);
    sync_index = this.sync_lex.indexOf(result[result.length - 1]);
    sync_len = this.sync_lex.length;
    if (sync_index > -1 && sync_index !== sync_len - 1 && this.stack === result) {
      last_stmt_index = result.lastIndexOf(this.sync_lex[this.sync_lex.length - 1]);
      result = result.slice(0, last_stmt_index + 1).concat(this.sync_lex[sync_index + 1]);
    }
    if (result) {
      stack_changed = this.stack !== result;
      value_assign = result.length > this.stack.length ? true : false;
      if (stack_changed) {
        this.stack = result;
        return this.reduce(syntax_table, value_assign);
      }
    }
  };

  SyntaxParser.prototype.generateTree = function(value_assign) {
    var curr_len, curr_node_leaves_len, curr_stack, i, new_gt, _i, _ref;
    curr_stack = this.stack.slice();
    curr_len = curr_stack.length;
    curr_node_leaves_len = this.tree.leaves.length;
    if (curr_len > curr_node_leaves_len) {
      new_gt = new GrammarNode(curr_stack[curr_len - 1], this.tree);
    } else {
      for (i = _i = 0, _ref = curr_len - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (!this.tree.leaves[i].isName(curr_stack[i])) {
          break;
        }
      }
      new_gt = new GrammarNode(curr_stack[curr_len - 1]);
      while (i++ !== curr_node_leaves_len) {
        this.tree.leaves.pop().linkParent(new_gt, true);
      }
      new_gt.linkParent(this.tree);
    }
    if (value_assign) {
      SyntaxParser.Mix(['SyntaxNode', new_gt], ['Lex', this.raw_input_lex[this.raw_input_lex.length - this.input_val.length]]);
      return new_gt.value = this.input_val.shift();
    }
  };

  SyntaxParser.prototype.parseTable = function(syntax_table) {
    var i, len, _i, _results;
    len = this.input_lex.length - 1;
    _results = [];
    for (i = _i = 1; 1 <= len ? _i <= len : _i >= len; i = 1 <= len ? ++_i : --_i) {
      this.shift(syntax_table);
      log(this.stack, 'before reduce');
      this.reduce(syntax_table);
      _results.push(log(this.stack, 'after reduce'));
    }
    return _results;
  };

  SyntaxParser.Mix = function() {
    if (!SyntaxParser.Mix.mixer) {
      return null;
    }
    return SyntaxParser.Mix.mixer.apply(this, arguments);
  };

  SyntaxParser.rebuild = function(syntax_node, mix_map, parent) {
    var leaf, _i, _len, _ref, _results;
    if (typeof syntax_node.parent === 'string') {
      syntax_node.parent = parent;
    }
    if (mix_map && syntax_node['__MixMapID__']) {
      mix_map.refs[syntax_node['__MixMapID__']] = syntax_node;
    }
    if (syntax_node.leaves) {
      _ref = syntax_node.leaves;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        leaf = _ref[_i];
        _results.push(SyntaxParser.rebuild(leaf, mix_map, syntax_node));
      }
      return _results;
    }
  };

  if (typeof self === 'undefined') {
    module.exports.SyntaxTable = SyntaxTable;
    module.exports.SyntaxParser = SyntaxParser;
    module.exports.AST = AST;
  } else {
    self.SyntaxTable = SyntaxTable;
    self.SyntaxParser = SyntaxParser;
    self.AST = AST;
  }

  log = function() {};

  return;

  log = util.log;

}).call(this);

//# sourceMappingURL=LR1-parser.js.map
