<template>
  <div>
    <svg-icon icon-class="question" @click="goto" />
  </div>
</template>

<script>
export default {
  name: 'RuoYiDoc',
  data() {
    return {
      url: '#'
    }
  },
  methods: {
    goto() {
      this.$message.info('文档正在建设中...')
    }
  }
}
</script>