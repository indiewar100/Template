# DP

## 背包

### 01背包
- normal
$f_i = max(f_i,f_i − v +w)$
需要按照 i 从大到小的顺序更新，确保每个物品只会选一次
```cpp
memset(dp,0xcf,sizeof dp);
dp[0] = 0;
rep(i,0,n)
{
	cin >> v[i] >> w[i];
	per(j,v[i],m+1)
	{
		dp[j] = max(dp[j],dp[j-v[i]]+w[i]);
	}
}
```
- 计数
不超过m的方案数
$f_i += f_i − v$

- 删除
加入物品的顺序不影响结果，假设被删除的物品是最后一次加入的，那么倒过来还原即可。
$f_i -= f_i − v$
需要按照 i 从小到大的顺序更新.
给定ai和bi，表示第i个商店有ai个商品可以买，单价为bi元，给出m个询问，问用c元在l~r商店买东西的方案数
一种物品的背包可以看成$\sum_{i=0}^{a}x^{ib}=\frac{1-x^{(a+1)b}}{1-x^b}$，所以可以先用(a+1)b去做一个01背包(系数为负)，再除以一个x^b的(系数为负)01背包。
从生成函数来看，$\frac{1}{1-x^b}=\sum_{i=0}^{\infty}x^{bi}$，即做一遍完全背包就可以等效

然后对可逆背包的预处理，由于$\frac{1-x^b}{1-x^{(a+1)*b}}=(1-x^b)*\sum_{i=0}^{\infty}x^{i*(a+1)b}$，于是反过来对x^b做01背包，对(a+1)b做完全背包就可以

```cpp
int n,m;
int a[maxn*10],b[maxn*10],f[maxn*10][maxn],g[maxn*10][maxn];

void gao(int *dp,int w)
{
	per(i,w,maxn)
	{
		dp[i] = (dp[i] - dp[i-w]+mod)%mod;
	}
}

void gao2(int *dp,int w)
{
	rep(i,w,maxn)
	{
		dp[i] = (dp[i] + dp[i-w]+mod)%mod;
	}
}

int main(int argc, char const *argv[])
{
	ios_base::sync_with_stdio(false), cin.tie(0);
	// cout.tie(0);
	int T,cas;
	cin >> T;
	cas = 1;
	f[0][0] = 1;
	rep(i,0,maxn)
		g[0][i] = 1;
	while(T--)
	{
		prr(cas++);
		cin >> n >> m;
		rep(i,1,n+1)
		{
			cin >> a[i] >> b[i];
			a[i] = (a[i] + 1) * b[i];
		}
		rep(i,1,n+1)
		{
			memcpy(f[i],f[i-1],sizeof(f[i]));
			memcpy(g[i],g[i-1],sizeof(g[i]));
			gao(f[i],a[i]);gao2(f[i],b[i]);
			gao(g[i],b[i]);gao2(g[i],a[i]);
		}
		int ans = 0;
		rep(i,0,m)
		{
			int l,r,c;
			cin >> l >> r >> c;
			l = (l+ans)%n+1;
			r = (r+ans)%n+1;
			if(l > r)
			{
				swap(l,r);
			}
			ans = 0;
			rep(i,0,c+1)
			{
				ans = (ans + 1ll*f[r][i]*g[l-1][c-i])%mod;
			}
			printf("%d\n",ans);
		}
	}
	return 0;
}
```

### 完全背包

- normal 
需要按照i从小到大的顺序更新，意为要么停止选，要么接着多选一个。
```cpp
dp[0] = 0;
rep(i,0,n)
{
	cin >> v >> w;
	rep(j,v,m+1)
	{
		dp[j] = max(dp[j],dp[j-v]+w);
	}
}
cout << dp[m] << endl;
```
- 计数
same
- 删除
same

###  多组背包
- 二进制拆分
二进制拆分，将一个物品拆成 O(logk) 个 01 背包的物品。 
eg:$10 = 1 + 2 + 4 + 3$，可以表示 $1-10$
O(nmlog(k))
```cpp
memset(dp,0,sizeof dp);
	rep(i,0,n)
	{
		cin >> v[i] >> w[i] >> s[i];
	}
	int cnt = 0;
	rep(i,0,n)
	{
		for(int j = 1;j < s[i];j <<= 1)
		{
			ww[cnt] = j * w[i];
			vv[cnt] = j * v[i];
			s[i] -= j;
			cnt++;
		}
		if(s[i])
		{
			ww[cnt] = s[i] * w[i];
			vv[cnt++] = s[i] * v[i];
		}
	}
	rep(i,0,cnt)
	{
		per(j,vv[i],m+1)
		{
			dp[j] = max(dp[j],dp[j-vv[i]] + ww[i]);
		}
	}
	cout << dp[m] << endl;
```


- 单调队列
按%v的余数分组，每组滑窗求区间最大值
O(nm),但不见得比上面快

### 分组背包
$n$个物品，每个物品只能选一个，体积为$vi$，种类为 $ki$。
求总体积恰好$m$的情况下能拿走物品种类数的最大值。 
将所有物品按 k 分组
状态：$f_{i,j,k,s}$ 表示考虑前 i 组，这一组内考虑了前 j 个物品，总体积为 k，
第 i 组物品是否被选择的情况为 s 时，种类数的最大值。 

### 树形依赖背包
以1为根的树上有 n 个节点，每个节点有一个物品，
体积 vi，价值 wi。
选了一个点就必须选它的父亲。
求总体积不超过 m 的情况下能拿走物品总价值的最大值。
