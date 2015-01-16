template = document.getElementById('main').innerHTML
ractive = new Ractive do
    el: '#main',
    template: template
    data: doc <<< showEditor: false,
    he: ->
        @set('showEditor', false)
    se: ->
        @set('showEditor', true)

ractive.on 'save' ->
    r <- superagent.put(location.pathname)
        .send doc{content}
        .end!
    alert '保存成功'

ractive.observe 'content', (newValue) ->
    ractive.set 'html', marked(newValue)

setImmediate = window.setImmediate or ->
    args = [].slice.call(arguments)
    args.splice(1, 0, 1)
    setTimeout.apply this, args
clearImmediate = window.clearImmediate or window.clearTimeout

textarea = document.querySelector('#editor textarea')
body = document.body
shouldSync = true
function syncScrollTop (triggerFromBody)
    timer = null
    return (ev) ->
        ev.stopPropagation!
        if timer or not shouldSync
            return
        shouldSync := false
        timer := setTimeout doSync, 100
        function doSync()
            _syncScrollTop(triggerFromBody)
            timer := null


function _syncScrollTop (triggerFromBody)
    bst = body.scrollTop
    bsh = body.scrollHeight
    tst = textarea.scrollTop
    tsh = textarea.scrollHeight
    # bst/bsh === tst/tsh
    if triggerFromBody
        br = bst/bsh
        st = Math.floor(tsh * br)
        shouldSync := false
        textarea.scrollTop = st
        setImmediate ->
            shouldSync := true
    else
        tr = tst/tsh
        st = Math.floor(bsh * tr)
        shouldSync := false
        body.scrollTop = st
        setImmediate ->
            shouldSync := true

window.addEventListener 'scroll', syncScrollTop(true), false
textarea.addEventListener 'scroll', syncScrollTop(false), false

window.addEventListener('hashchange', _, false) (ev) ->
    if location.hash is '#edit'
        document.body.classList.add \edit-enable
    else
        document.body.classList.remove \edit-enable

window.addEventListener('load', _, false) (ev) ->
    if location.hash is '#edit'
        location.hash = ''
