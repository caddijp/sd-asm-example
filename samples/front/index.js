const express = require('express')
const app = express()
const axios = require('axios').default;

const port = 3000

const BACKEND = "http://backend:3100"

app.get('/hello', (req, res) => {
  axios.get(`${BACKEND}/api`).then(resp => {
    if (resp.status == 200) {
      res.send({result: resp.data.answer * 2})
    } else {
      res.send({result: "error" + resp.statusText})
    }
  }).catch(e => res.send({result: "error" }))
})

app.listen(port, () => {
  console.log(`front app listening on port ${port}`)
})
