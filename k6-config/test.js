import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { target: 10, duration: '10m' },
    { target: 0, duration: '30s' },
  ],
};

export default function () {
  const result = http.get('http://node-hpa-example:8080/getLoad');
  check(result, {
    'http response status code is 200': result.status === 200,
  });
}
