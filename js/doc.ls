vm = new Vue do
    el: '#main',
    data: doc <<< showEditor: false,
    filters: do
        marked: marked
    methods: do
        he: ->
            @$set('showEditor', false)
        se: ->
            @$set('showEditor', true)
        save: ->
            r <- superagent.put(location.pathname)
                .send doc{content}
                .end!
            alert '保存成功'

vm.$watch 'content', (newValue) ->
    console.log newValue
    setTextareaHeight()

textarea = document.querySelector('#editor textarea')

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
