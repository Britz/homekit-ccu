/*
 * File: HomeMaticRegaRequest.js
 * Project: homekit-ccu
 * File Created: Saturday, 7th March 2020 2:30:06 pm
 * Author: Thomas Kluge (th.kluge@me.com)
 * -----
 * The MIT License (MIT)
 *
 * Copyright (c) Thomas Kluge <th.kluge@me.com> (https://github.com/thkl)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * ==========================================================================
 */
'use strict'

var http = require('http')

// Module-level queue shared across all instances — Rega is single-threaded,
// concurrent requests cause socket hang-ups.
var _regaQueue = []
var _regaRunning = false

function _enqueue(fn) {
  return new Promise((resolve, reject) => {
    _regaQueue.push({ fn, resolve, reject })
    _drain()
  })
}

function _drain() {
  if (_regaRunning || _regaQueue.length === 0) return
  _regaRunning = true
  var entry = _regaQueue.shift()
  entry.fn().then(
    (result) => { _regaRunning = false; entry.resolve(result); _drain() },
    (err) => { _regaRunning = false; entry.reject(err); _drain() }
  )
}

class HomeMaticRegaRequest {
  constructor(log, ccuIP = '127.0.0.1', timeout = 120) {
    this.log = log
    this.isRemote = ccuIP && ccuIP !== '127.0.0.1'
    this.ccuIP = ccuIP
    this.timeout = timeout
  }

  _attempt(script) {
    var self = this
    return new Promise((resolve, reject) => {
      var postOptions = {
        host: this.ccuIP,
        port: this.isRemote ? '8181' : '8183',
        path: '/tclrega.exe',
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': script.length
        }
      }

      var postReq
      try {
        postReq = http.request(postOptions, (res) => {
          var data = ''
          res.setEncoding('binary')
          res.on('data', (chunk) => { data += chunk.toString() })
          res.on('end', () => {
            var pos = data.lastIndexOf('<xml><exec>')
            var response = data.substring(0, pos)
            self.log.debug('[Rega] result is %s', response)
            resolve(response)
          })
        })
      } catch (e) {
        self.log.error(e)
        reject(new Error('Rega request Error'))
        return
      }

      postReq.on('error', (e) => { reject(e) })
      postReq.on('timeout', () => {
        postReq.destroy()
        reject(new Error('TimeOut'))
      })
      postReq.setTimeout(this.timeout * 1000)
      postReq.write(script)
      postReq.end()
    })
  }

  script(script, retries = 3, retryDelay = 5) {
    var self = this
    self.log.debug('[Rega] RegaScript %s', script)
    return _enqueue(() => new Promise((resolve, reject) => {
      var attempt = (remaining) => {
        self._attempt(script).then(resolve).catch(e => {
          if (remaining > 0) {
            self.log.warn('[Rega] script failed (%s), retrying in %ds (%d retries left)', e.message, retryDelay, remaining)
            setTimeout(() => attempt(remaining - 1), retryDelay * 1000)
          } else {
            self.log.error('[Rega] script failed after all retries: %s', e.message)
            reject(e)
          }
        })
      }
      attempt(retries)
    }))
  }

  setValue(hmadr, value) {
    return new Promise((resolve, reject) => {
      // check explicitDouble
      if (typeof value === 'object') {
        let v = value['explicitDouble']
        if (v !== undefined) {
          value = v
        }
      }
      this.log.debug('Rega SetValue %s of %s', value, hmadr.address())
      var script = 'var d = dom.GetObject("' + hmadr.address() + '");if (d){d.State("' + value + '");}'
      this.script(script).then(data => resolve(data)).catch(err => reject(err))
    })
  }

  setVariable(channel, value) {
    return new Promise((resolve, reject) => {
      var script = 'var d = dom.GetObject("' + channel + '");if (d){d.State("' + value + '");}'
      this.script(script).then(data => resolve(data)).catch(err => reject(err))
    })
  }

  getVariable(channel) {
    return new Promise((resolve, reject) => {
      var script = 'var d = dom.GetObject("' + channel + '");if (d){Write(d.State());}'
      this.script(script).then(data => resolve(data)).catch(err => reject(err))
    })
  }

  isInt(n) {
    return Number(n) === n && n % 1 === 0
  }

  isFloat(n) {
    return n === Number(n) && n % 1 !== 0
  }
}

module.exports = HomeMaticRegaRequest
