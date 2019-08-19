// This file contains the source for the Javascript side of the
// WebViewJavascriptBridge. It is plaintext, but converted to an NSString
// via some preprocessor tricks.
//
// Previous implementations of WebViewJavascriptBridge loaded the javascript source
// from a resource. This worked fine for app developers, but library developers who
// included the bridge into their library, awkwardly had to ask consumers of their
// library to include the resource, violating their encapsulation. By including the
// Javascript as a string resource, the encapsulation of the library is maintained.

#import "WebViewJavascriptBridge_JS.h"

NSString * WebViewJavascriptBridge_js() {
#define __wvjb_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__wvjb_js_func__(
                                                             ;(function() {
//        if (window.Ti || window.QXBridge) { return }
        var messagingIframe;
        var sendMessageQueue = [];
        var receiveMessageQueue = [];
        var messageHandlers = {};
        
        var CUSTOM_PROTOCOL_SCHEME = 'ytx';
        var QUEUE_HAS_MESSAGE = '__QX_QUEUE_MESSAGE__';
        
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function isAndroid(){
            var ua = navigator.userAgent.toLowerCase();
            var isA = ua.indexOf("android") > -1;
            if(isA){
                return true;
            }
            return false;
        }
        
        function _createQueueReadyIframe(doc) {
            messagingIframe = doc.createElement('iframe');
            messagingIframe.style.display = 'none';
            messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
            doc.documentElement.appendChild(messagingIframe);
        }
        
        function init(messageHandler) {
            if (QXBridge._messageHandler) { throw new Error('QXBridge.init called twice') }
            QXBridge._messageHandler = messageHandler;
            var receivedMessages = receiveMessageQueue;
            receiveMessageQueue = null;
            for (var i=0; i<receivedMessages.length; i++) {
                _dispatchMessageFromQX(receivedMessages[i]);
            }
        }
        
        function send(data, responseCallback) {
            _doSend({ data:data }, responseCallback);
        }
        
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function callHandler(handlerName, data, responseCallback) {
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            sendMessageQueue.push(message);
            messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        }
        
        function _fetchQueue() {
            var messageQueueString = JSON.stringify(sendMessageQueue);
            sendMessageQueue = [];
            _setResultValue('_fetchQueue', messageQueueString);
            return messageQueueString;
        }
        
        function _setResultValue(scene, result) {
            if(!!isAndroid())
                messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://return/' + scene + '/' + result;
        }
        
        function _dispatchMessageFromQX(messageJSON) {
            setTimeout(function _timeoutDispatchMessageFromQX() {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) { return; }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            _doSend({ responseId:callbackResponseId, responseData:responseData });
                        }
                    }
                    
                    var handler = QXBridge._messageHandler;
                    if (message.handlerName) {
                        handler = messageHandlers[message.handlerName];
                    }
                    
                    try {
                        handler(message.data, responseCallback);
                    } catch(exception) {
                        if (typeof console != 'undefined') {
                            console.log("QXBridge: WARNING: javascript handler threw.", message, exception);
                        }
                    }
                }
            });
        }
        
        function _handleMessageFromQX(messageJSON) {
            if (receiveMessageQueue) {
                receiveMessageQueue.push(messageJSON);
            } else {
                _dispatchMessageFromQX(messageJSON);
            }
        }
        
        window.QXBridge = window.Ti = {
        init: init,
        send: send,
            
        registerHandler: registerHandler,
        callHandler: callHandler,
            
        addEventListener: registerHandler,
        fireEvent: callHandler,
            
        _fetchQueue: _fetchQueue,
        _handleMessageFromQX: _handleMessageFromQX
        };
        
        var doc = document;
        _createQueueReadyIframe(doc);
        var readyEvent = doc.createEvent('Events');
        readyEvent.initEvent('QXBridgeReady');
        readyEvent.bridge = QXBridge;
        doc.dispatchEvent(readyEvent);
    })();
                                                             
                                                             ); // END preprocessorJSCode
    
#undef __wvjb_js_func__
    return preprocessorJSCode;
};
