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

按照DFS的顺序进行DP。
往下搜的时候，强行将儿子选入背包中。 
往上回溯的时候，可以选择要这棵子树的DP值，或者不要。

## 数位DP
```cpp
int a[20];
ll dp[20][state];
ll dfs(int pos,/*state变量*/,bool lead/*前导零*/,bool limit)
{
    
    if(pos==-1) return 1;
    //第二个就是记忆化(在此前可能不同题目还能有一些剪枝)
    if(!limit && !lead && dp[pos][state]!=-1) return dp[pos][state];
    int up=limit?a[pos]:9;
    ll ans=0;
    for(int i=0;i<=up;i++)
    {
        if() ...
        else if()...
        ans+=dfs(pos-1,/*状态转移*/,lead && i==0,limit && i==a[pos]);
    }
    //计算完，记录状态
    if(!limit && !lead) dp[pos][state]=ans;
    return ans;
}
ll solve(ll x)
{
    int pos=0;
    while(x)
    {
        a[pos++]=x%10;
        x/=10;
    }
    return dfs(pos-1/*从最高位开始枚举*/,/*一系列状态 */,true,true);
}
```

### 数位上不能有4也不能有连续的62
dp[pos][sta]表示当前第pos位，前一位是否是6的状态，这里sta只需要去0和1两种状态就可以了，不是6的情况可视为同种，不会影响计数
```cpp
#include<iostream>
#include<cstdio>
#include<cstring>
#include<string>
using namespace std;
typedef long long ll;
int a[20];
int dp[20][2];
int dfs(int pos,int pre,int sta,bool limit)
{
    if(pos==-1) return 1;
    if(!limit && dp[pos][sta]!=-1) return dp[pos][sta];
    int up=limit ? a[pos] : 9;
    int tmp=0;
    for(int i=0;i<=up;i++)
    {
        if(pre==6 && i==2)continue;
        if(i==4) continue;//都是保证枚举合法性
        tmp+=dfs(pos-1,i,i==6,limit && i==a[pos]);
    }
    if(!limit) dp[pos][sta]=tmp;
    return tmp;
}
int solve(int x)
{
    int pos=0;
    while(x)
    {
        a[pos++]=x%10;
        x/=10;
    }
    return dfs(pos-1,-1,0,true);
}
int main()
{
    int le,ri;
    //memset(dp,-1,sizeof dp);可优化
    while(~scanf("%d%d",&le,&ri) && le+ri)
    {
        memset(dp,-1,sizeof dp);
        printf("%d\n",solve(ri)-solve(le-1));
    }
    return 0;
}
```

### 优化
memset(dp,-1,sizeof dp);放在多组数据外面
使用的条件是：约束条件是每个数自身的属性，而与输入无关。
1.求数位和是10的倍数的个数,这里简化为数位sum%10这个状态，即dp[pos][sum]这里10 是与多组无关的，所以可以memset优化，不过注意如果题目的模是输入的话那就不能这样了。

2.求二进制1的数量与0的数量相等的个数，这个也是数自身的属性。

### 相减
约束就是一个数的二进制中0的数量要不能少于1的数量
dp[pos][num],到当前数位pos,0的数量减去1的数量不少于num的方案数，一个简单的问题，中间某个pos位上num可能为负数(这不一定是非法的，因为我还没枚举完嘛，只要最终的num>=0才能判合法，中途某个pos就不一定了)，7最小就-32吧(好像),直接加上32，把32当0用。

lead的用法，显然我要统计0的数量，前导零是有影响的。
```cpp
#pragma comment(linker, "/STACK:10240000,10240000")
#include<iostream>
#include<cstdio>
#include<cstring>
#include<string>
#include<queue>
#include<set>
#include<vector>
#include<map>
#include<stack>
#include<cmath>
#include<algorithm>
using namespace std;
const double R=0.5772156649015328606065120900;
const int N=1e5+5;
const int mod=1e9+7;
const int INF=0x3f3f3f3f;
const double eps=1e-8;
const double pi=acos(-1.0);
typedef long long ll;
int dp[35][66];
int a[66];
int dfs(int pos,int sta,bool lead,bool limit)
{
    if(pos==-1)
        return sta>=32;
    if(!limit && !lead && dp[pos][sta]!=-1) return dp[pos][sta];
    int up=limit?a[pos]:1;
    int ans=0;
    for(int i=0;i<=up;i++)
    {
        if(lead && i==0) ans+=dfs(pos-1,sta,lead,limit && i==a[pos]);//有前导零就不统计在内
        else ans+=dfs(pos-1,sta+(i==0?1:-1),lead && i==0,limit && i==a[pos]);
    }
    if(!limit && !lead ) dp[pos][sta]=ans;
    return ans;
}
int solve(int x)
{
    int pos=0;
    while(x)
    {
        a[pos++]=x&1;
        x>>=1;
    }
    return dfs(pos-1,32,true,true);
}
int main()
{
    memset(dp,-1,sizeof dp);
    int a,b;
    while(~scanf("%d%d",&a,&b))
    {
        printf("%d\n",solve(b)-solve(a-1));
    }
    return 0;
}
```

### 计数转求和
要求数的平方和。
先考虑求和的问题，一个区间，数位dp能在一些约束下计数，现在要这些数的和。其实组合数学搞搞就可以了：如 现在枚举的某一位pos,我统计了这一位枚举i的满足条件的个数cnt，其实只要算i对总和的贡献就可以了，对于一个数而言第pos位是i，那么对求和贡献就是i*10^pos,就是十进制的权值，然后有cnt个数都满足第pos位是i，最后sum=cnt*i*10^pos.

原理就是这样平方和可以看做(a*10^pos+b)^2,a是你当前pos位要枚举的，b其实是个子问题，就是pos之后的位的贡献值，把这个平方展开.
```cpp
typedef long long ll;
ll fact[20];
void init()
{
    fact[0]=1;
    for(int i=1;i<20;i++)
        fact[i]=fact[i-1]*10%mod;
}
struct node
{
    ll cnt,sum,sqr;
    node(ll cnt=-1,ll sum=0,ll sqr=0):cnt(cnt),sum(sum),sqr(sqr){}
}dp[20][7][7];
int a[20];
ll fac(ll x)
{
    return x*x%mod;
}
ll dfs(int pos,ll num,ll val,ll&cnt,ll&sum,bool limit)
{
    if(pos==-1) {
        if(num==0 || val==0)
            return 0;
        cnt=1;
        return 0;
    }
    if(!limit && dp[pos][num][val].cnt!=-1) {
            cnt=dp[pos][num][val].cnt;
            sum=dp[pos][num][val].sum;
            return dp[pos][num][val].sqr;
    }
    int up=limit?a[pos]:9;
    ll sq=0;
    for(int i=0;i<=up;i++)
    if(i!=7)
    {
        ll cn=0,su=0;
        ll tmp=dfs(pos-1,(num+i)%7,(val*10+i)%7,cn,su,limit && i==a[pos]);
        ll tm=i*fact[pos]%mod;
        tmp=(tmp+fac(tm)*cn%mod+(tm*su%mod)*2%mod)%mod;//计数之后要更新sum,sqr
        sum=(sum+su+(i*fact[pos]%mod)*cn%mod)%mod;
        cnt=(cnt+cn)%mod;
        sq=(sq+tmp)%mod;
    }
    if(!limit) dp[pos][num][val]=node(cnt,sum,sq);
    return sq;
}
ll solve(ll x)
{
    int pos=0;
    while(x)
    {
        a[pos++]=x%10;
        x/=10;
    }
    ll t1=0,t2=0;
    return dfs(pos-1,0,0,t1,t2,true);
}
bool judge(ll x)
{
    int sum=0;
    int pos=0;
    if(x%7==0) return false;
    while(x)
    {
        if(x%10==7) return false;
        sum+=x%10;
        x/=10;
    }
    sum%=7;
    return sum!=0;
}
int main()
{
    init();
    for(int i=0;i<20;i++)
        for(int j=0;j<7;j++)
        for(int k=0;k<7;k++)//memset
    {
        dp[i][j][k].cnt=-1;
        dp[i][j][k].sum=0;
        dp[i][j][k].sqr=0;
    }
    int T_T;
    scanf("%d",&T_T);
    while(T_T--)
    {
        ll le,ri;
        scanf("%I64d%I64d",&le,&ri);
        ll ans=solve(ri)-solve(le-1);
        ans=(ans%mod+mod)%mod;
        printf("%I64d\n",ans);
    }
    return 0;
}
```