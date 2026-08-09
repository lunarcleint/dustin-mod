//
private static var debug_charSelectRemember:Int;

function postCreate() {
    if (debug_charSelectRemember != null && debug_charSelectRemember != 0)
        tree[tree.length -1].changeSelection(debug_charSelectRemember - 1);
}

function destroy() {
    debug_charSelectRemember = tree[tree.length -1].members.indexOf(tree[tree.length -1].curOption);
}