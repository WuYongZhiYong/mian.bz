template = document.getElementById('main').innerHTML
console.log template
console.log doc
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
    console.log newValue
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
        console.log 'tfb ', triggerFromBody
        console.log 'timer ', timer
        console.log 'shouldSync ', shouldSync
        if timer or not shouldSync
            return
        shouldSync := false
        timer := setTimeout doSync, 100
        function doSync()
            console.log 'doSync'
            console.log 'tfb ', triggerFromBody
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
        console.log st
        shouldSync := false
        textarea.scrollTop = st
        setImmediate ->
            console.log 'simb'
            shouldSync := true
    else
        tr = tst/tsh
        st = Math.floor(bsh * tr)
        console.log st
        shouldSync := false
        body.scrollTop = st
        setImmediate ->
            console.log 'simt'
            shouldSync := true
    console.log tr
    console.log br

window.addEventListener 'scroll', syncScrollTop(true), false
textarea.addEventListener 'scroll', syncScrollTop(false), false
/*
    setTextareaHeight()


function setTextareaHeight ()
    wst = window.scrollTop
    textarea.style.height = '1px'
    height = Math.max(document.documentElement.clientHeight, textarea.scrollHeight)
    if textarea.offsetHeight isnt height
        textarea.style.height = height + 'px'
        window.scrollTop = wst

setTextareaHeight()
window.setTextareaHeight = setTextareaHeight

setTimeout(setTextareaHeight, 1000)
*/
