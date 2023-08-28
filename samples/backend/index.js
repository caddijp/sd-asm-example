const express = require('express')
const app = express()
const port = 3100

app.get('/api', (req, res) => {
  res.send({answer: 42})
})

app.listen(port, () => {
  console.log(`backend app listening on port ${port}`)
})