<template>

    <div class="app">
        <web-view ref="reflectName" class="webview" @ready="webReady" @stateChanged="webState"></web-view>
        <icon v-if="loadIng" class="icon"></icon>
    </div>

</template>

<style scoped>
    .app {
        position: relative;
    }
    .webview {
        flex: 1;
        scrollEnabled: false;
        progressbarVisibility: false;
        progressbarVisibility: false;
    }
    .icon {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        content: "tb-loading-c spin";
        font-size: 48px;
        color: #666666;
    }
</style>

<script>
    const weiui = app.requireModule('weiui');

    export default {
        name: 'WEcharts',

        props: {
            baidukey: {
                type: String,
                default: "706afcb60ea4460e246fe6a24c73e0c5",
            },

            options: {
                type: Object,
                default: {
                    title: {
                        text: '基本的折线图（演示）'
                    },
                    xAxis: {
                        type: 'category',
                        data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    },
                    yAxis: {
                        type: 'value'
                    },
                    series: [{
                        data: [820, 932, 901, 934, 1290, 1330, 1320],
                        type: 'line'
                    }]
                }
            },
        },

        data() {
            return {
                loadIng: true
            }
        },

        mounted() {
            weiui.setVariate("components::echarts::baidukey", this.baidukey);
            weiui.setVariate("components::echarts::option", JSON.stringify(this.options));
        },

        watch: {
            options(option) {
                this.setOptions(option);
            }
        },

        methods: {
            webReady() {
                this.$refs.reflectName.setUrl(weiui.rewriteUrl('../components/WEcharts/echarts.html'));
            },

            webState(data) {
                if (data.status === 'start') {
                    this.loadIng = true;
                }else if (data.status === 'success' || data.status === 'error') {
                    this.loadIng = false;
                }
            },

            setOptions(option) {
                weiui.setVariate("components::echarts::option", JSON.stringify(option));
                this.$refs.reflectName.setJavaScript("if (typeof loadOption == 'function') { loadOption() }");
            }
        }
    }
</script>

