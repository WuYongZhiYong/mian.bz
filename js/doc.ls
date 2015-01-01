new Vue do
    el: '#editor',
    data: doc,
    filters: do
        marked: marked
    methods: do
        save: ->
            r <- superagent.put(location.pathname)
                .send doc{content}
                .end!
            alert '保存成功'
