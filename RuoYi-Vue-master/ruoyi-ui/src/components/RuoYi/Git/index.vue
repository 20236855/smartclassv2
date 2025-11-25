<template>
  <div>
    <svg-icon icon-class="github" @click="goto" />
  </div>
</template>

<script>
export default {
  name: 'RuoYiGit',
  data() {
    return {
      url: '#'
    }
  },
  methods: {
    goto() {
      this.$message.info('源码仓库正在建设中...')
    }
  }
}
</script>